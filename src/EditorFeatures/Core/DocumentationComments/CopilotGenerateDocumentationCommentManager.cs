// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using System;
using System.Collections.Immutable;
using System.ComponentModel.Composition;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.CodeAnalysis.Copilot;
using Microsoft.CodeAnalysis.Editor.Shared.Utilities;
using Microsoft.CodeAnalysis.Host.Mef;
using Microsoft.CodeAnalysis.Shared.Extensions;
using Microsoft.CodeAnalysis.Shared.TestHooks;
using Microsoft.CodeAnalysis.Text;
using Microsoft.VisualStudio.Text;
using Microsoft.VisualStudio.Text.Editor;
using Roslyn.Utilities;

namespace Microsoft.CodeAnalysis.DocumentationComments;

[Export(typeof(CopilotGenerateDocumentationCommentManager))]
internal sealed class CopilotGenerateDocumentationCommentManager
{
    // Helix: the inline prompt chip needs InlinePromptServiceBase from the VS 18 editor, which the
    // 17.14 editor fork does not have, so typing '///' only leaves the normal doc-comment skeleton.
    [ImportingConstructor]
    [Obsolete(MefConstruction.ImportingConstructorMessage, error: true)]
    public CopilotGenerateDocumentationCommentManager()
    {
    }

    public void TriggerDocumentationCommentProposalGeneration(Document document,
        DocumentationCommentSnippet snippet, ITextSnapshot snapshot, VirtualSnapshotPoint caret, ITextView textView, CancellationToken cancellationToken)
    {
    }

    /// <summary>
    /// Applies the generated documentation edits to <paramref name="buffer"/> in a single transaction. The edit
    /// spans are positions in <paramref name="snapshot"/> (captured when the chip was shown), so they are
    /// translated to the buffer's current snapshot in case it changed before the user accepted.
    /// </summary>
    internal static void ApplyEdits(ITextBuffer buffer, ITextSnapshot snapshot, ImmutableArray<DocumentationCommentEdit> edits)
    {
        var currentSnapshot = buffer.CurrentSnapshot;
        using var bufferEdit = buffer.CreateEdit();
        foreach (var edit in edits)
        {
            var span = new SnapshotSpan(snapshot, edit.SpanToReplace.Start, edit.SpanToReplace.Length)
                .TranslateTo(currentSnapshot, SpanTrackingMode.EdgeInclusive);
            bufferEdit.Replace(span, edit.ReplacementText);
        }

        bufferEdit.Apply();
    }
}
