B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private FindForm As Form
	Private HexView1 As HexView
	Private Visible As Boolean
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(HV As HexView)
	FindForm.Initialize("FindForm",350,600)
	HexView1 = HV
		
End Sub

Public Sub Form As Form
	Return FindForm
End Sub

Public Sub Show(Form1 As Form)
	Dim Found As Boolean
	
	Dim FCwidth As Double

	If "" & FindForm.WindowWidth = "NaN" Then
		FCwidth = 300
	Else
		FCwidth = FindForm.WindowWidth
	End If
	
	For Each Sc As Screen In fx.Screens
		If Form1.WindowLeft + Form1.WindowWidth + FCwidth <= Sc.MaxX Then
			FindForm.WindowTop = Form1.WindowTop
			FindForm.WindowLeft = Form1.WindowLeft + Form1.WindowWidth
			FindForm.WindowHeight = Form1.WindowHeight
			Found = True
			Exit
		End If
	Next
	
	If Found = False Then
		For Each Sc As Screen In fx.Screens
			If Form1.WindowLeft >= FCwidth Then
				FindForm.WindowTop = Form1.WindowTop
				FindForm.WindowLeft = Form1.WindowLeft - FCwidth
				FindForm.WindowHeight = Form1.WindowHeight
				Found = True
				Exit
			End If
		Next
	End If
	
	If Found = False Then
		FindForm.WindowTop = Form1.WindowTop
		FindForm.WindowLeft = Form1.WindowLeft + Form1.WindowWidth - FCwidth
		FindForm.WindowHeight = Form1.WindowHeight
	End If
	
	FindForm.Show
	Visible = True
End Sub

Private Sub FindForm_CloseRequest (EventData As Event)
	HexView1.FoundList.Clear
	HexView1.lvFind.Items.Clear
	HexView1.lblFindInfo.Text = ""
	HexView1.RemoveHighlights("All","")
	Visible = False
End Sub

Public Sub Hide
	FindForm.Close
End Sub

Public Sub IsVisisble As Boolean
	Return Visible
End Sub