param($xs, $ys,
      $title = $null,
      $legend = $null,
      $xs2 = $null,
      $ys2 = $null)
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization
$Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
$ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$ChartTypes = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]

$Series = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.Series
$Series.ChartType = $ChartTypes::Line
$Series.Points.DataBindXY($xs, $ys)
$Chart.Series.Add($Series)

if ($xs2 -and $ys2) {
    $Series = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.Series
    $Series.ChartType = $ChartTypes::Line
    $Series.Points.DataBindXY($xs2, $ys2)
    $Chart.Series.Add($Series)
}

$Chart.ChartAreas.Add($ChartArea)

$Chart.Width = 700
$Chart.Height = 400
$Chart.Left = 10
$Chart.Top = 10
$Chart.BackColor = [System.Drawing.Color]::White
$Chart.BorderColor = 'Black'
$Chart.BorderDashStyle = 'Solid'
if ($title) {
    $ChartTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title
    $ChartTitle.Text = $title
    $Font = New-Object System.Drawing.Font @('Microsoft Sans Serif','12', [System.Drawing.FontStyle]::Bold)
    $ChartTitle.Font =$Font
    $Chart.Titles.Add($ChartTitle)
}
if ($legend) {
    $Legend = New-Object System.Windows.Forms.DataVisualization.Charting.Legend
    $Legend.IsEquallySpacedItems = $True
    $Legend.BorderColor = 'Black'
    $Chart.Legends.Add($Legend)
    $Chart.Series["Series1"].LegendText = $legend
}

#region Windows Form to Display Chart
$AnchorAll = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor
    [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
$Form = New-Object Windows.Forms.Form
$Form.Width = 740
$Form.Height = 490
$Form.Text = "Chart: $title"
$Form.controls.add($Chart)
$Chart.Anchor = $AnchorAll

if ($false) {
    # add a save button
    $SaveButton = New-Object Windows.Forms.Button
    $SaveButton.Text = "Save"
    $SaveButton.Top = 420
    $SaveButton.Left = 600
    $SaveButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    # [enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
    $SaveButton.add_click({
        $Result = Invoke-SaveDialog
        If ($Result) {
            $Chart.SaveImage($Result.FileName, $Result.Extension)
        }
    })
    $Form.controls.add($SaveButton)
}

if ($true) {
    # add a quit button
    $QuitButton = New-Object Windows.Forms.Button
    $QuitButton.Text = "Quit"
    $QuitButton.Top = 420
    $QuitButton.Left = 400
    $QuitButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
    # [enum]::GetNames('System.Windows.Forms.DataVisualization.Charting.ChartImageFormat')
    $QuitButton.add_click({
        $this.Parent.Close()
    })
    $Form.controls.add($QuitButton)
}

$Form.Add_Shown({$Form.Activate()})
[void]$Form.ShowDialog()
#endregion Windows Form to Display Chart
