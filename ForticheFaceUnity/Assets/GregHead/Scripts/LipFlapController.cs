using System;
using UnityEngine;

public class LipFlapController : MonoBehaviour
{
    private BlendWrapper mouthOpen;
    private BlendWrapper mouthRight;
    private BlendWrapper mouthLeft;
    private BlendWrapper mouthUp;

    private Vector2 startDrag;
    private bool wasPressed;

    private HeadOrchestrator headMain;

    private void Start()
    {
        headMain = GetComponent<HeadOrchestrator>();
        mouthOpen = new BlendWrapper("Vis_Ae_Ax_Ah_01", headMain);
        mouthRight = new BlendWrapper("Jaw_Chew_Right", headMain);
        mouthLeft = new BlendWrapper("Jaw_Chew_Left", headMain);
        mouthUp = new BlendWrapper("Chin_Raised", headMain);
    }

    public void DoUpdate()
    {
        bool isPressed = Input.GetMouseButton(1);
        if (isPressed)
        {
            if(wasPressed)
            {
                Vector2 currentPos = Input.mousePosition;
                Vector2 delta = currentPos - startDrag;
                UpdateMouth(delta);
            }
            else
            {
                startDrag = Input.mousePosition;
            }
        }
        else
        {
            UpdateMouth(Vector2.zero);
        }
        wasPressed = isPressed;
    }

    private void UpdateMouth(Vector2 delta)
    {
        float upTarget = delta.y / 100;
        upTarget = Mathf.Clamp01(upTarget);
        mouthUp.Update(upTarget);

        float downTarget = -delta.y / 100;
        downTarget = Mathf.Clamp01(downTarget);
        mouthOpen.Update(downTarget);

        float leftTarget = delta.x / 100;
        leftTarget = Mathf.Clamp01(leftTarget);
        mouthLeft.Update(leftTarget);

        float rightTarget = -delta.x / 100;
        rightTarget = Mathf.Clamp01(rightTarget);
        mouthRight.Update(rightTarget);
    }

    private class BlendWrapper
    {
        private readonly SkinnedMeshRenderer renderer;
        private readonly int index;
        private float currentVal;

        public BlendWrapper(string name, HeadOrchestrator orchestrator)
        {
            renderer = orchestrator.HeadMesh;
            index = orchestrator.GetBlendIndex(name);
        }

        public void Update(float target)
        {
            currentVal = Mathf.Lerp(currentVal, target, Time.deltaTime * 15);
            renderer.SetBlendShapeWeight(index, currentVal * 100);
        }
    }
}

public class PitchAndVolumeSource : MonoBehaviour
{
    private float currentDecibels;
    private float minDecibels;
    private float maxDecibels;
    private float currentPitch;


    [Header("Volume")]
    [SerializeField]
    private float volumeAdjustmentOffsetDB = 0;
    [SerializeField]
    private float volumeAdjustmentScaleDB = 5;
    [SerializeField]
    private float volumeRangeDB = 160;
    [SerializeField]
    private float volumeBlendSpeed = 10.0f;

    [Header("Pitch")]
    [SerializeField]
    private float pitchAdjustmentOffset = 0;
    [SerializeField]
    private float pitchAdjustmentScale = 2;
    [SerializeField]
    private float pitchRange = 1000;
    [SerializeField]
    private float pitchBlendSpeed = 3.0f;

    private float[] audioSamples;
    private float[] audioSpectrum;

    [SerializeField]
    private int audioSampleSize = 256;
    [SerializeField]
    private float audioReferenceValue = 0.1f;
    [SerializeField]
    private float audioThreshold = 0.02f;
    [SerializeField]
    private int audioAverageRange = 1;

    [SerializeField]
    private bool useDynamicRange = true;

    private SimpleMovingAverage smoothedDecibelRange;
    private SimpleMovingAverage dyanmicDecibelRange;
    private SimpleMovingAverage smoothedPitch;

    private void Awake()
    {
        audioSamples = new float[audioSampleSize];
        audioSpectrum = new float[audioSampleSize];
        dyanmicDecibelRange = new SimpleMovingAverage(512);
        smoothedDecibelRange = new SimpleMovingAverage(audioAverageRange);
        smoothedPitch = new SimpleMovingAverage(audioAverageRange);

        minDecibels = 0.0f;
        maxDecibels = AudioHelper.MinDB;
    }

    [SerializeField]
    private AudioSource audioSource;

    private float normalizedVolume;
    private float normalizedPitch;

    private void Update()
    {
        UpdatePitchAndVolume();
    }

    private void SetVolumeLevels()
    {
        float volumeDB = AudioHelper.GetDecibelScale(audioSamples, audioReferenceValue);
        smoothedDecibelRange.AddSample(volumeDB);
        currentDecibels = smoothedDecibelRange.Average;

        dyanmicDecibelRange.AddSample(currentDecibels);
        minDecibels = dyanmicDecibelRange.Min;
        maxDecibels = dyanmicDecibelRange.Max;
    }

    private float GetNormalizedPitch()
    {
        float ret = Mathf.Clamp01((Mathf.Abs(currentPitch + pitchAdjustmentOffset)) / pitchRange) * pitchAdjustmentScale;
        ret = ret * 2 - 1;
        return ret;
    }
    private float GetNormalizedVolume()
    {
        if (useDynamicRange)
        {
            float adjustedMinDB = Mathf.Max(AudioHelper.MinDB, minDecibels);
            float adjustedMaxDB = maxDecibels;
            float adjustedDB = Mathf.Abs(Mathf.Clamp(currentDecibels, adjustedMinDB, adjustedMaxDB) - adjustedMaxDB);
            float adjustedDBRange = Mathf.Abs(adjustedMaxDB - adjustedMinDB);

            if (adjustedDBRange > 0)
            {
                return 1 - Mathf.Clamp01((adjustedDB / adjustedDBRange) * volumeAdjustmentScaleDB);
            }
            return 0;
        }
        else
        {
            // Use direct volume to drive normalized value
            // Convert DB to normalized range [0 (loud), -160 (quiet)] -> [0 (quiet), 1 (loud)]
            return (1 - Mathf.Clamp01((Mathf.Abs(currentDecibels + volumeAdjustmentOffsetDB)) / volumeRangeDB)) * volumeAdjustmentScaleDB;
        }
    }

    private void UpdatePitchAndVolume()
    {
        audioSource.GetOutputData(audioSamples, 0);
        audioSource.GetSpectrumData(audioSpectrum, 0, FFTWindow.BlackmanHarris);
        SetVolumeLevels();

        smoothedPitch.AddSample(AudioHelper.ComputePitch(audioSpectrum, audioThreshold));
        currentPitch = smoothedPitch.Average;
        normalizedPitch = GetNormalizedPitch();
        normalizedVolume = GetNormalizedVolume();
    }

}

public static class AudioHelper
{
    public const float MinDB = -80.0f;//-160.0f;

    public static float GetRootMeanSquare(float[] buffer)
    {
        // sum of squares
        float sos = 0f;

        for (int i = 0; i < buffer.Length; i++)
        {
            float val = buffer[i];
            sos += val * val;
        }

        // return sqrt of average
        return Mathf.Max(Mathf.Sqrt(sos / buffer.Length), MinDB);
    }

    public static float GetDecibelScale(float[] buffer, float refPower = 1.0f)
    {
        float rootMeanSquare = GetRootMeanSquare(buffer);
        refPower = Mathf.Max(0.01f, refPower);

        float volumeDB = 20 * Mathf.Log10(rootMeanSquare / refPower);
        return float.IsNegativeInfinity(volumeDB) ? MinDB : volumeDB;
    }

    public static float ComputePitch(float[] audioSpectrum, float audioThreshold)
    {
        float maxV = 0;
        int maxN = 0;
        for (int i = 0; i < audioSpectrum.Length; i++)
        {
            if (!(audioSpectrum[i] > maxV) || !(audioSpectrum[i] > audioThreshold))
            {
                continue;
            }

            maxV = audioSpectrum[i];
            maxN = i;
        }
        float freqN = maxN;
        if (maxN > 0 && maxN < audioSpectrum.Length - 1)
        {
            float dL = audioSpectrum[maxN - 1] / audioSpectrum[maxN];
            float dR = audioSpectrum[maxN + 1] / audioSpectrum[maxN];
            freqN += 0.5f * (dR * dR - dL * dL);
        }
        float pitch = freqN * (AudioSettings.outputSampleRate / 2) / audioSpectrum.Length;
        return pitch;
    }
}

public class SimpleMovingAverage
{
    private float[] sampleBuffer;
    private double currentSummation;
    private int currentSize;
    private int currentSampleIndex;

    public float Average
    {
        get { return currentSize > 0 ? (float)(currentSummation / currentSize) : 0.0f; }
    }

    public float Min
    {
        get
        {
            float minValue = float.MaxValue;

            float length = Mathf.Min(currentSize, sampleBuffer.Length);
            for (int i = 0; i < length; i++)
            {
                minValue = Mathf.Min(minValue, sampleBuffer[i]);
            }

            return minValue;
        }
    }

    public float Max
    {
        get
        {
            float maxValue = float.MinValue;

            float length = Mathf.Min(currentSize, sampleBuffer.Length);
            for (int i = 0; i < length; i++)
            {
                maxValue = Mathf.Max(maxValue, sampleBuffer[i]);
            }

            return maxValue;
        }
    }

    public SimpleMovingAverage(int sampleCount)
    {
        sampleBuffer = new float[sampleCount];
    }

    public void AddSample(float sampleValue)
    {
        // Remove old value from summation
        currentSummation -= sampleBuffer[currentSampleIndex];

        // Insert new value and add to summation
        sampleBuffer[currentSampleIndex] = sampleValue;
        currentSummation += sampleValue;

        // Increase and wrap sample index
        currentSampleIndex = (currentSampleIndex + 1) % sampleBuffer.Length;

        // Update size, which will max out at length of sample buffer
        currentSize = System.Math.Max(currentSize, currentSampleIndex + 1);
    }
}