$pptxPath = (Resolve-Path "outputs\business_insights_pitch.pptx").Path
$pdfPath = [System.IO.Path]::ChangeExtension($pptxPath, ".pdf")

Write-Host "Opening PowerPoint..."
$ppt = New-Object -ComObject PowerPoint.Application
$pres = $ppt.Presentations.Open($pptxPath, $false, $false, $false)
Write-Host "Saving as PDF..."
$pres.SaveAs($pdfPath, 32)
$pres.Close()
$ppt.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($ppt) | Out-Null
[GC]::Collect()
[GC]::WaitForPendingFinalizers()

if (Test-Path $pdfPath) {
    Write-Host "PDF exported successfully to: $pdfPath"
} else {
    Write-Error "PDF export failed."
}
