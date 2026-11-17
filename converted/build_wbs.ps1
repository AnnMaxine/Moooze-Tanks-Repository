$ErrorActionPreference = 'Stop'
$base = $PSScriptRoot
$items = Get-Content -Raw -LiteralPath (Join-Path $base 'wbs-layout.json') | ConvertFrom-Json
$app = New-Object -ComObject Visio.Application
$app.Visible = $false
$app.AlertResponse = 7
try {
    $doc = $app.Documents.Add('')
    $page = $doc.Pages.Item(1)
    $page.Name = 'Work Breakdown Structure'
    $page.PageSheet.CellsU('PageWidth').ResultIU = 2048/72
    $page.PageSheet.CellsU('PageHeight').ResultIU = 1181/72
    $shapes = @{}
    foreach ($item in $items) {
        $shape = $page.DrawRectangle($item.x/72, (1181-$item.y-$item.h)/72, ($item.x+$item.w)/72, (1181-$item.y)/72)
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
        $parent = $shapes[$item.parent]
        $child = $shapes[$item.id]
        $connector = $page.Drop($app.ConnectorToolDataObject,0,0)
        $connector.CellsU('LineColor').FormulaU = 'RGB(85,85,85)'
        $connector.CellsU('LineWeight').FormulaU = '0.6 pt'
        $connector.CellsU('EndArrow').FormulaU = '4'
        $connector.CellsU('EndArrowSize').FormulaU = '0'
        $connector.CellsU('BeginX').GlueTo($parent.CellsU('PinX'))
        $connector.CellsU('EndX').GlueTo($child.CellsU('PinX'))
        $connector.SendToBack()
    }
    $title = $page.DrawRectangle(970/72, (1181-233)/72, 1255/72, (1181-184)/72)
    $title.Text = "MOOOZE TANKS`nWORK BREAKDOWN STRUCTURE"
    $title.CellsU('LinePattern').FormulaU = '0'
    $title.CellsU('FillPattern').FormulaU = '0'
    $title.CellsU('Char.Color').FormulaU = 'RGB(210,89,12)'
    $title.CellsU('Char.Size').FormulaU = '18 pt'
    $title.CellsU('Para.HorzAlign').FormulaU = '1'
    $title.CellsU('VerticalAlign').FormulaU = '1'
    $logo = $page.Import((Join-Path $base 'wbs-logo.png'))
    $logo.CellsU('Width').ResultIU = 143/72
    $logo.CellsU('Height').ResultIU = 143/72
    $logo.CellsU('PinX').ResultIU = 1112/72
    $logo.CellsU('PinY').ResultIU = (1181-93)/72
    $output = Join-Path $base 'WBS.vsdx'
    $doc.SaveAs($output)
    $page.Export((Join-Path $base 'WBS-preview.png'))
    Write-Output "Saved $output; shapes: $($page.Shapes.Count)"
    $doc.Close()
    $check = $app.Documents.Open($output)
    Write-Output "Reopened: $($check.Pages.Count) page, $($check.Pages.Item(1).Shapes.Count) shapes"
    $check.Close()
} finally {$app.Quit()}
