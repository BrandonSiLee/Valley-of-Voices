## Turns an HTML file into a Word .docx using Microsoft Word (installed on Brandon's PC).
## Used by /wrap-up to make Brandon's end-of-day copy of his design doc.
param(
	[Parameter(Mandatory)] [string]$HtmlPath,
	[Parameter(Mandatory)] [string]$DocxPath
)
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
try {
	$doc = $word.Documents.Open((Resolve-Path -LiteralPath $HtmlPath).Path, $false, $true)
	# 16 = wdFormatDocumentDefault (.docx)
	$doc.SaveAs2([string]$DocxPath, 16)
	$doc.Close($false)
	"saved: $DocxPath"
}
finally {
	$word.Quit()
	[void][Runtime.InteropServices.Marshal]::ReleaseComObject($word)
}
