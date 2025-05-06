B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8
@EndOfDesignText@
Sub Class_Globals
	Private fx As JFX
	Private XUI As XUI
	Private AForm As Form
	Private mForm As Form
	Private pnLicence As Pane
	Private LicenceText As String
	Private lblVersion As B4XView								'Ignore
	Private btnLicence As Button								'Ignore
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(F As Form,Version As String)
	mForm = F
	AForm.Initialize("AForm",400,300)
	AForm.RootPane.LoadLayout("aboutlayout")
	lblVersion.Text = Version
End Sub

Public Sub Form As Form
	Return AForm
End Sub

Public Sub Show
	AForm.WindowLeft = mForm.WindowLeft + (mForm.WindowWidth - 400) / 2
	AForm.WindowTop = mForm.WindowTop + (mForm.WindowHeight - 300) / 2
	AForm.ShowAndWait
End Sub

Public Sub SetLicence(Text As String)
	LicenceText = Text
	If LicenceText = "" Then 
		btnLicence.Visible = False
	Else
		btnLicence.Visible = True
	End If
End Sub

Sub btnLicence_Click
	pnLicence.Initialize("pnLicence")
	Dim LblLicence As Label
	LblLicence.Initialize("lblLicence")
	pnLicence.AddNode(LblLicence,10,10,380,280)
	AForm.RootPane.AddNode(pnLicence,0,0,400,300)
	LblLicence.WrapText = True
	Dim PL As B4XView = pnLicence
	PL.Color = XUI.Color_White
	LblLicence.Text = LicenceText
End Sub

Private Sub pnLicence_MouseClicked (EventData As MouseEvent)
	pnLicence.RemoveNodeFromParent
End Sub