$ErrorActionPreference = 'Stop'
$base = $PSScriptRoot
$items = Get-Content -Raw -LiteralPath (Join-Path $base 'wbs-original-layout.json') | ConvertFrom-Json
$app = New-Object -ComObject Visio.Application
$app.Visible = $false
$app.AlertResponse = 7
try {
    $doc = $app.Documents.Add('')
    $page = $doc.Pages.Item(1)
    $page.Name = 'Work Breakdown Structure'
    $page.PageSheet.CellsU('PageWidth').ResultIU = 2963/104.168
    $page.PageSheet.CellsU('PageHeight').ResultIU = 1709/104.168
    $shapes = @{}
    foreach ($item in $items) {
        $shape = $page.DrawRectangle($item.x/104.168, (1709-$item.y-$item.h)/104.168, ($item.x+$item.w)/104.168, (1709-$item.y)/104.168)
        $shape.NameU = 'WBS_'+$item.id
        $shape.Text = $item.text
        $shape.CellsU('Char.Size').FormulaU = '8 pt'
        $shape.CellsU('Para.HorzAlign').FormulaU = '1'
        $shape.CellsU('VerticalAlign').FormulaU = '1'
        $shape.CellsU('LineWeight').FormulaU = '0.5 pt'
        $shape.CellsU('LineColor').FormulaU = 'RGB(150,150,150)'
        $shape.CellsU('FillForegnd').FormulaU = 'RGB(255,255,255)'
        $shape.CellsU('LeftMargin').FormulaU = '2 pt'
        $shape.CellsU('RightMargin').FormulaU = '2 pt'
        $shape.CellsU('TopMargin').FormulaU = '1 pt'
        $shape.CellsU('BottomMargin').FormulaU = '1 pt'
        if ($item.color -eq 'yellow') {$shape.CellsU('FillForegnd').FormulaU = 'RGB(255,211,20)'}
        if ($item.color -in @('dark','orange')) {
            $shape.CellsU('FillForegnd').FormulaU = $(if ($item.color -eq 'dark') {'RGB(200,78,0)'} else {'RGB(255,147,43)'})
            $shape.CellsU('Char.Color').FormulaU = 'RGB(255,255,255)'
            $shape.CellsU('Char.Style').FormulaU = '1'
            $shape.CellsU('Char.Size').FormulaU = '10 pt'
        }
        $shapes[$item.id] = $shape
    }
    foreach ($item in $items) {
        if (-not $item.parent) {continue}
        [double[]]$points = @($item.route | ForEach-Object { $_[0]/104.168; (1709-$_[1])/104.168 })
        $connector = $page.DrawPolyline($points, 0)
        $connector.NameU = 'OriginalRoute_'+$item.id
        $connector.CellsU('LineColor').FormulaU = 'RGB(40,40,40)'
        $connector.CellsU('LineWeight').FormulaU = '0.65 pt'
        $connector.CellsU('FillPattern').FormulaU = '0'
        $connector.CellsU('EndArrow').FormulaU = '4'
        $connector.CellsU('EndArrowSize').FormulaU = '0'
        $connector.SendToBack()
    }
    $title = $page.DrawRectangle(1400/104.168, (1709-330)/104.168, 1815/104.168, (1709-270)/104.168)
    $title.Text = "MOOOZE TANKS`nWORK BREAKDOWN STRUCTURE"
    $title.CellsU('LinePattern').FormulaU = '0'
    $title.CellsU('FillPattern').FormulaU = '0'
    $title.CellsU('Char.Color').FormulaU = 'RGB(210,89,12)'
    $title.CellsU('Char.Size').FormulaU = '14 pt'
    $title.CellsU('Para.HorzAlign').FormulaU = '1'
    $title.CellsU('VerticalAlign').FormulaU = '1'
    $logo = $page.Import((Join-Path $base 'wbs-logo.png'))
    $logo.CellsU('Width').ResultIU = 206/104.168
    $logo.CellsU('Height').ResultIU = 206/104.168
    $logo.CellsU('PinX').ResultIU = 1608/104.168
    $logo.CellsU('PinY').ResultIU = (1709-134)/104.168
    $output = Join-Path (Split-Path $base) 'WBS-Original-Lines.vsdx'
    $doc.SaveAs($output)
    $page.Export((Join-Path $base 'WBS-original-lines-preview.png'))
    Write-Output "Saved $output; shapes: $($page.Shapes.Count)"
    $doc.Close()
} finally {$app.Quit()}
