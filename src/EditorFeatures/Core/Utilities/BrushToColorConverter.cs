// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using System;
using System.Globalization;
using System.Linq;
using System.Windows.Data;
using System.Windows.Media;

namespace Microsoft.CodeAnalysis.Utilities;

internal sealed class BrushToColorConverter : IValueConverter
{
    public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        => value switch
        {
            SolidColorBrush solidColorBrush => solidColorBrush.Color,
            GradientBrush gradientBrush => gradientBrush.GradientStops.FirstOrDefault()?.Color ?? Colors.Transparent,
            _ => Colors.Transparent
        };

    public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        => throw new NotSupportedException();
}
