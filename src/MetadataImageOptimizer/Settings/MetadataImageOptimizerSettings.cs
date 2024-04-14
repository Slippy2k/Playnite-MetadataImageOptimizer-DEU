using System.Collections.Generic;
using Playnite.SDK.Data;
using SixLabors.ImageSharp.Formats.Png;
using SixLabors.ImageSharp.Formats.Webp;

namespace MetadataImageOptimizer.Settings
{
    public class MetadataImageOptimizerSettings : ObservableObject
    {
        private bool alwaysOptimizeOnSave;
        private bool runInBackground;
        private ImageTypeSettings background;
        private ImageTypeSettings cover;
        private ImageTypeSettings icon;
        private QualitySettings quality;

        public MetadataImageOptimizerSettings()
        {
            SetDefaults();
        }

        [DontSerialize]
        public Dictionary<string, string> AvailableImageFormats { get; } = new Dictionary<string, string>
        {
            { "jpg", "JPG" }
            , { "png", "PNG" }
            , { "webp", "WebP (Lossy)" }
        };

        public bool AlwaysOptimizeOnSave { get => alwaysOptimizeOnSave; set => SetValue(ref alwaysOptimizeOnSave, value); }
        public bool RunInBackground { get => runInBackground; set => SetValue(ref runInBackground, value); }
        public ImageTypeSettings Background { get => background; set => SetValue(ref background, value); }
        public ImageTypeSettings Cover { get => cover; set => SetValue(ref cover, value); }
        public ImageTypeSettings Icon { get => icon; set => SetValue(ref icon, value); }
        public QualitySettings Quality { get => quality; set => SetValue(ref quality, value); }

        private void SetDefaults()
        {
            background = new ImageTypeSettings
            {
                Format = "webp"
                , MaxHeight = 720
                , MaxWidth = 1280
                , Optimize = true
            };

            cover = new ImageTypeSettings
            {
                Format = "webp"
                , MaxHeight = 900
                , MaxWidth = 600
                , Optimize = true
            };

            icon = new ImageTypeSettings
            {
                Format = "webp"
                , MaxHeight = 64
                , MaxWidth = 64
                , Optimize = true
            };

            quality = new QualitySettings
            {
                JpgQuality = 80
                , PngCompressionLevel = PngCompressionLevel.Level6
                , WebpEncodingMethod = WebpEncodingMethod.Level4
                , WebpQuality = 80
            };
        }
    }
}
