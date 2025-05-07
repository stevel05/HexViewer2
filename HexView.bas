B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8
@EndOfDesignText@
'Hexview distributed to B4x forums : https://www.b4x.com/android/forum/threads/b4j-hex-view-customview.112588/post-701943
'Author Stevel05 
'(c) 2019 Stevel05
'
'This code is provided free for the benefit of the B4x Community. If you use this code or a derivitive in a commercial 
'application or benefit from the utility, please consider donating to the author to keep the goodwill flowing 
'and encourage the provision of more examples and support. 
'
#DesignerProperty: Key: BackgroundColor, DisplayName: Background Color , FieldType: Color, DefaultValue: 0x00000000, Description: Background color for the HexView table
#DesignerProperty: Key: TextColor, DisplayName: Text Color , FieldType: Color, DefaultValue: 0xFF000000, Description: Text Color for the HexView
#DesignerProperty: Key: ShowHeader, DisplayName: Show Header, FieldType: Boolean, DefaultValue: True, Description: Show Header
#DesignerProperty: Key: MaxResults, DisplayName: Maximum Results, FieldType: Int, DefaultValue: 20000, Description: The maximum number of results to return from find
#DesignerProperty: Key: HeaderBackgroundColor, DisplayName: Header Background Color , FieldType: Color, DefaultValue: 0xFFA8A8A8, Description: Background Color for the Header
#DesignerProperty: Key: HeaderTextColor, DisplayName: Header Text Color , FieldType: Color, DefaultValue: 0xFF444444, Description: Text Color for the Header
#DesignerProperty: Key: HighlightColor, DisplayName: Highlight Color , FieldType: Color, DefaultValue: 0xF000FFFF, Description: Color for the highlight
#DesignerProperty: Key: FollowingHighlightColor, DisplayName: Following Highlight Color  , FieldType: Color, DefaultValue: 0xFFABFFFF, Description: Color for the following highlight
#DesignerProperty: Key: FindHighlightColor, DisplayName: Find Highlight Color , FieldType: Color, DefaultValue: 0xF0FFFF00, Description: Color for the Find highlight
#DesignerProperty: Key: FollowingFindHighlightColor, DisplayName: Following Find Highlight Color  , FieldType: Color, DefaultValue: 0xF0FFFF7A, Description: Color for the following Find highlight
#DesignerProperty: Key: SelectedHighlightColor, DisplayName: Selected Highlight Color , FieldType: Color, DefaultValue: 0xF059FF45, Description: Color for the Selected highlight
#DesignerProperty: Key: FollowingSelectedHighlightColor, DisplayName: Following Selected Highlight Color  , FieldType: Color, DefaultValue: 0xF0A2FF99, Description: Color for the following Selected highlight
'Custom View class
Sub Class_Globals
	Type HighlightType(Rect As B4XRect,HType As String,HighlightColor As Int,Data As Byte)
	Type FindType(Index As Int, TargetIndex As Int)
	
	Private fx As JFX
	Private XUI As XUI
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Private mBase As Pane
	Private Scrollbar1 As ScrollBar
	
	Private PageData() As Byte
	Private DataStore() As Byte
	Private PageLength As Int = 10
	Private Cnv As B4XCanvas
	Private CnvHighlights As B4XCanvas
	Private mFont As B4XFont
	Private LineHeight As Double
	Private LineWidth As Double
	Private CharWidth As Double = 9
	Private ColumnCount As Int = 61
	Private DataStartX As Int = 5
	Private CurrentFileDir,CurrentFileName As String
	Private CurrentOffset As Int
	Private HexViewBG As B4XView
	Private mTextColor As Int
	Private mHeaderTextColor As Int
	Private mHeaderBackgroundColor As Int
	Private mShowHeader As Boolean
	Private ReservedHeaderLines As Int = 2
	Dim HeaderLines As Int = 0
	Private ColumnStart(4),ColumnWidths(4) As Int
	Private mHighlightColor,mFollowingHighlightColor As Int
	Private mFindHighlightColor,mFollowingFindHighlightColor As Int
	Private mSelectedHighlightColor, mFollowingSelectedHighlightColor As Int
	Private Highlights(4) As List
	Private KEH As KeyEventHelper
	Private lblInfo As Label
	Private FindTargetBytes() As Byte
	Public FoundList As List
	Public FindInterrupt As Boolean
	Private CurrentFindType As FindType
	Private Scrollbar1KeepFindHighlights As Boolean
	Private mForm As Form
	Private StartDragPos As Int = -1
	
	Private MenuBar1 As MenuBar									'ignore
	Private FindForm As FindClass
	Private TFString As TextField								'Ignore
	Private TFChr As TextField									'Ignore
	Public	lblFindInfo As Label								'Ignore
	Private pbFind As ProgressBar								'Ignore
	Public lvFind As ListView									'Ignore
	Private tfOffset As TextField								'Ignore
	Private pnNav As B4XView									'Ignore
	Private NumberSpinnerCV1 As NumberSpinnerCV					'Ignore
	Private lblFoundCount As B4XView							'Ignore
	Private mMaxResults As Int = 9999
	Private Version As String = "v1.4"
	
	
	Private AboutClass1 As AboutClass

	
End Sub

Public Sub Initialize (Callback As Object, EventName As String)
	mEventName = EventName
	mCallBack = Callback
	mFont = XUI.CreateFont(fx.CreateFont("Monospaced",14,False,False),14)
	ColumnStart = Array As Int(1,10,29,46)
	ColumnWidths = Array As Int(8,16,16,16)
	FoundList.Initialize
	For i = 0 To 3
		Highlights(i).Initialize
	Next
End Sub

Public Sub DesignerCreateView (Base As Pane, Lbl As Label, Props As Map)
	mBase = Base
	mBase.LoadLayout("hexview")
	CreateMenu
	HexViewBG.Color = XUI.PaintOrColorToColor(Props.GetDefault("BackgroundColor",XUI.Color_Transparent))
	mTextColor = XUI.PaintOrColorToColor(Props.GetDefault("TextColor",XUI.Color_Black))
	mHeaderTextColor = XUI.PaintOrColorToColor(Props.GetDefault("HeaderTextColor",XUI.Color_ARGB(0xFF,0x44,0x44,0x44)))
	mHeaderBackgroundColor = XUI.PaintOrColorToColor(Props.GetDefault("HeaderBackgroundColor",XUI.Color_ARGB(0xFF,0xA8,0xA8,0xA8)))
	mHighlightColor = XUI.PaintOrColorToColor(Props.GetDefault("HighlightColor",XUI.Color_ARGB(0xF0,0x00,0xFF,0xFF)))
	mFollowingHighlightColor = XUI.PaintOrColorToColor(Props.GetDefault("FollowingHighlightColor",XUI.Color_ARGB(0xFF,0xAB,0xFF,0xFF)))
	mFindHighlightColor = XUI.PaintOrColorToColor(Props.GetDefault("FindHighlightColor",XUI.Color_ARGB(0xF0,0xFF,0xFF,0x00)))
	mFollowingFindHighlightColor = XUI.PaintOrColorToColor(Props.GetDefault("FollowingFindHighlightColor",XUI.Color_ARGB(0xF0,0xFF,0xFF,0x7A)))
	mSelectedHighlightColor = XUI.PaintOrColorToColor(Props.GetDefault("SelectedHighlightColor",XUI.Color_ARGB(0xF0,0x59,0xFF,0x45)))
	mFollowingSelectedHighlightColor = XUI.PaintOrColorToColor(Props.GetDefault("FollowingSelectedHighlightColor",XUI.Color_ARGB(0xF0,0xA2,0xFF,0x99)))
	mMaxResults = Props.GetDefault("MaxResults",20000)
	mShowHeader = Props.GetDefault("ShowHeader",True)
	mForm = Props.Get("Form")
	Cnv.Initialize(HexViewBG)
	CnvHighlights.Initialize(HexViewBG)
	Scrollbar1.Initialize
	Scrollbar1.SetOrientation("VERTICAL")
	Scrollbar1.SetValueListener(Me,"Scrollbar1")
	
	setFont(fx.CreateFont("Monospaced",14,False,False))
	mBase.Tag = Me
	
	mBase.AddNode(Scrollbar1.GetObject,mBase.Width - 20,HexViewBG.Top,20,HexViewBG.Height)
	
	KEH.Initialize
	KEH.SetKeyEvent(HexViewBG,KEH.KEY_PRESSED,Me,"HexViewBG")
	
	Dim JO As JavaObject = mBase
	Dim O As JavaObject = JO.CreateEventFromUI("javafx.event.EventHandler","BaseScroll",Null)
	JO.RunMethod("setOnScroll",Array(O))
	HexViewBG.RequestFocus
End Sub

Public Sub Close
	If FindForm.IsInitialized Then FindForm.Hide
End Sub

Public Sub setForm(f As Form)
	mForm = f
End Sub

Private Sub CreateMenu
	MenuBar1.Menus.Clear
	
	Dim FileMenu As Menu
	FileMenu.Initialize("File","Menu")
	FileMenu.MenuItems.Add(NewMenuItem("Open","Menu",Array As String("Ctrl","O")))
	
	Dim FindMenu As Menu
	FindMenu.Initialize("Find","Menu")
	FindMenu.MenuItems.Add(NewMenuItem("Find","Menu",Array As String("F3")))
	
	
	Dim HelpMenu As Menu
	HelpMenu.Initialize("Help","Menu")
	HelpMenu.MenuItems.Add(NewMenuItem("About","Menu",Array As String("F1")))
	
	MenuBar1.Menus.Addall(Array(FileMenu,FindMenu,HelpMenu))  
	
End Sub

Private Sub Menu_Action
	Dim Mi As MenuItem = Sender
	Select Mi.Text
		Case "Open"
			Dim FC As FileChooser
			FC.Initialize
			Dim FN As String = FC.ShowOpen(mForm)
			If FN <> "" Then
				LoadFile(File.GetFileParent(FN),File.GetName(FN))
			End If
		Case "Find"
			If FindForm.IsInitialized = False Then
				FindForm.Initialize(Me)
				ClassLoadLayout(FindForm.Form,"findform")
			End If
			tfOffset.Text = ""
			TFString.Text = ""
			
			FindForm.Show(mForm)
			CallSubDelayed(Me,"Set_Find")
			
		Case "About"
			If AboutClass1.IsInitialized = False Then
				AboutClass1.Initialize(mForm,Version)
				Try
					AboutClass1.SetLicence(File.ReadString(File.DirAssets,"licence.txt"))
				Catch
					Log(LastException)
					AboutClass1.SetLicence($"Author Stevel05
(c) 2019-2025 Stevel05

This code is provided free for the benefit of the B4x Community. If you use this code or a derivitive in a commercial application or benefit financially from the utility, please consider donating to the author to keep the goodwill flowing and encourage the provision of more examples and support. 

Click To dismiss"$)
				End Try
			End If
			AboutClass1.Show
	End Select
End Sub

Sub btnLicence_Click
	AboutClass1.btnLicence_Click
End Sub

Private Sub Set_Find
	TFChr.RequestFocus
	TFChr.Text = GetSelectedData
	btnFind_Click
End Sub

Private Sub NewMenuItem(Text As String, EventName As String,KeyShortCut() As String) As MenuItem
	Dim MI As MenuItem
	MI.Initialize(Text,EventName)
	If KeyShortCut.Length > 0 Then
		HexV_Utils.SetShortCutKey(MI,KeyShortCut)
	End If
	Return MI
End Sub

Private Sub ClassLoadLayout(F As Form, Layout As String)
	F.RootPane.LoadLayout(Layout)
End Sub


Sub HexViewBG_KeyPressed(KEvt As KeyEvent)
	
	Select KEvt.GetCode.GetName
		Case "Page Up"
			RemoveHighlights("All","")
			Scrollbar1.AdjustValue((Scrollbar1.GetValue - PageLength) / Scrollbar1.GetMax)
		Case "Page Down"
			RemoveHighlights("All","")
			Scrollbar1.AdjustValue((Scrollbar1.GetValue + PageLength) / Scrollbar1.GetMax)
		Case "Home"
			RemoveHighlights("All","")
			Scrollbar1.SetValue(0)
		Case "End"
			RemoveHighlights("All","")
			Scrollbar1.SetValue(Scrollbar1.GetMax)
		Case "Up"
			RemoveHighlights("All","")
			Scrollbar1.Decrement
		Case "Down"
			RemoveHighlights("All","")
			Scrollbar1.Increment
	End Select
	
End Sub
Private Sub Base_Resize(Width As Double, Height As Double)
	HexViewBG_ResizeDo(Width - 20,Height - 60)
End Sub

Private Sub HexViewBG_ResizeDo (Width As Double, Height As Double)
	RemoveHighlights("All","")
	HexViewBG.SetLayoutAnimated(0,0,HexViewBG.Top,Width,Height)
	lblInfo.Top = HexViewBG.Top + Height
	Cnv.Resize(Width,Height)
	CnvHighlights.Resize(Width,Height)
	SizeFont
	HeaderLines = 0
	If mShowHeader Then HeaderLines = ReservedHeaderLines
	PageLength = Height / LineHeight - HeaderLines
	Scrollbar1.AsNode.Top = HexViewBG.Top + HeaderLines * LineHeight
	Scrollbar1.AsNode.Left = Width
	Scrollbar1.AsNode.PrefHeight = Height - HeaderLines * LineHeight
		
	ReadData(Scrollbar1.GetValue)
	
End Sub

Private Sub SizeFont
	
	mFont = XUI.CreateFont2(mFont,ResizeFont(mFont))
	lblInfo.Font = XUI.CreateFont(mFont,Min(mFont.Size,18))

	LineWidth = Cnv.MeasureText(GetChars(ColumnCount,"%"),mFont).Width
	CharWidth = LineWidth / ColumnCount
	LineHeight = Cnv.MeasureText("|",mFont).Height + 2
End Sub

Private Sub ResizeFont(SFont As Font) As Double
	Dim DrawnLineWidth As Int = (ColumnCount+2) * CharWidth 
	Dim Size As Double = SFont.Size
	Dim TFont As B4XFont = XUI.CreateFont2(SFont,Size)
	If Abs(DrawnLineWidth - Cnv.TargetRect.Width) > 0 Then
		Dim Ratio As Double = Cnv.TargetRect.Width / (DrawnLineWidth)
		Size = (Floor(Abs((TFont.Size * Ratio * 10)))/ 10)
		TFont = XUI.CreateFont2(TFont,Size)
	End If
	Return Size
End Sub

Private Sub Resize2(StartSize As Double) As Double								'Ignore
	Dim Str As String = GetChars(ColumnCount,"%")
	Dim Size As Double = 80
	Dim TFont As B4XFont = XUI.CreateFont2(mFont,Size)
	Do While Cnv.MeasureText(Str,TFont).Width > Cnv.TargetView.Width - CharWidth * 2
		Size = Size - 0.5
		TFont = XUI.CreateFont2(TFont,Size)
	Loop
	Return Size
End Sub

Public Sub BaseScroll_Event (MethodName As String, Args() As Object)
	Dim Evt As JavaObject = Args(0)
	
	If Evt.RunMethod("getDeltaY",Null) < 0 Then
		Scrollbar1.Increment
	Else
		Scrollbar1.Decrement
	End If
End Sub

Public Sub GetBase As Pane
	Return mBase
End Sub

Public Sub RemoveHighlights(HType As String,Keep As String)
	For i = 0 To 3
		For j = Highlights(i).Size - 1 To 0 Step - 1
			Dim HT As HighlightType = Highlights(i).Get(j)
			If HT.HType = HType Or (HType = "All" And HT.HType <> Keep) Then Highlights(i).RemoveAt(j)
		Next
	Next
	DrawHighlights
End Sub

Private Sub HexViewBG_MouseExited (EventData As MouseEvent)
	lblInfo.Text = "Offset"
End Sub

Private Sub HexViewBG_MouseMoved (EventData As MouseEvent)
	Dim Y As Double = EventData.Y
	
	RemoveHighlights("Highlight","")
	DrawHighlights
	
	lblInfo.Text = "Offset"
	
	If Y < 0 Or Y > (PageLength + HeaderLines + 1 ) * LineHeight Then Return
	
	Dim HT As HighlightType
	HT.Initialize
	Dim Top As Float = Floor(Y / LineHeight) * LineHeight
	HT.Rect.Initialize(0,Top,10, Top + LineHeight)
	Dim Pos As Int
	
	Select True
		Case EventData.X >= ColumnStart(3) * CharWidth And EventData.X <= (ColumnStart(3) + ColumnWidths(3)) * CharWidth
			
			Dim Line As Int = Floor(EventData.Y / LineHeight) - HeaderLines
			Dim Column As Int = Floor(EventData.X - ColumnStart(3) * CharWidth) / CharWidth
			Pos = Line * 16 + Column
			If Pos > PageData.Length - 1 Then Return
			
			HT.HType = "Highlight"
			HT.Rect.Left = Floor(EventData.X / CharWidth) * CharWidth
			HT.Rect.Width = CharWidth
			HT.HighlightColor = mHighlightColor
			Highlights(3).Add(HT)
			
			Dim SHT As HighlightType
			SHT.Initialize
			Dim Left As Float
			Dim HighlightIndex As Int
			If Column < 8 Then
				Left = (ColumnStart(1) + Column * 2) * CharWidth
				HighlightIndex = 1
			Else
				Left = (ColumnStart(2) + (Column - 8) * 2) * CharWidth
				HighlightIndex = 2
			End If
			SHT.Rect.Initialize(Left,HT.Rect.Top,Left + CharWidth * 2,HT.Rect.Bottom)
			SHT.HighlightColor = mFollowingHighlightColor
			SHT.HType = "Highlight"
			Highlights(HighlightIndex).Add(SHT)
			
		Case EventData.X >= ColumnStart(2) * CharWidth And EventData.X < (ColumnStart(2) + ColumnWidths(2)) * CharWidth
			
			Dim Line As Int = Floor(EventData.Y / LineHeight) - HeaderLines
			Dim Column As Int = Floor((Floor(EventData.X - ColumnStart(2) * CharWidth) / CharWidth) / 2) * 2
			Pos = Line * 16 + Column / 2 + 8
			If Pos > PageData.Length - 1 Then Return
			
			Dim Column As Int = Floor((Floor(EventData.X - ColumnStart(2) * CharWidth) / CharWidth) / 2) * 2
			HT.HType = "Highlight"
			HT.Rect.Left = (ColumnStart(2) + Column) * CharWidth
			HT.Rect.Width = CharWidth * 2
			HT.HighlightColor = mHighlightColor
			Highlights(2).Add(HT)
			
			Column = Column / 2 + 8
			Dim Left As Float = (ColumnStart(3) + Column) * CharWidth
			Dim SHT As HighlightType
			SHT.Initialize
			SHT.HType = "Highlight"
			SHT.Rect.Initialize(Left,HT.Rect.Top,Left + CharWidth,HT.Rect.Bottom)
			SHT.HighlightColor = mFollowingHighlightColor
			Highlights(3).Add(SHT)
			
		Case EventData.X >= ColumnStart(1) * CharWidth And EventData.X <= (ColumnStart(1) + ColumnWidths(1)) * CharWidth
			Dim Line As Int = Floor(EventData.Y / LineHeight) - HeaderLines
			Dim Column As Int = Floor((Floor(EventData.X - ColumnStart(1) * CharWidth) / CharWidth) / 2) * 2
			Pos = Line * 16 + Column / 2
			If Pos > PageData.Length - 1 Then Return
			
			HT.HType = "Highlight"
			HT.Rect.Left = (ColumnStart(1) + Column) * CharWidth
			HT.Rect.Width = CharWidth * 2
			HT.HighlightColor = mHighlightColor
			Highlights(1).Add(HT)
			
			Column = Column / 2
			Dim Left As Float = (ColumnStart(3) + Column) * CharWidth
			Dim SHT As HighlightType
			SHT.Initialize
			SHT.HType = "Highlight"
			SHT.Rect.Initialize(Left,HT.Rect.Top,Left + CharWidth,HT.Rect.Bottom)
			SHT.HighlightColor = mFollowingHighlightColor
			Highlights(3).Add(SHT)
			
		Case EventData.X >= ColumnStart(0) * CharWidth And EventData.X <= (ColumnStart(0) + ColumnWidths(0)) * CharWidth
			Return
		Case Else
			Return
	End Select
	
	Dim Str As String
	If Pos > -1 And Pos < PageData.Length Then
		Dim C As Byte = PageData(Pos)
		If C < 128 And C > 32 Then
			Str = Chr(C)
		Else
			Str = "·"
		End If

		Dim Offset As Int = Pos + CurrentOffset' + Floor((Y  / LineHeight) - HeaderLines ) * 16

		Dim JO As JavaObject = ""															'Ignore
		lblInfo.Text = $"Offset: Dec:${JO.RunMethod("format",Array("%8s",Array(Offset)))} Hex ${JO.RunMethod("format",Array("%08x",Array(Offset)))} Val: Dec ${JO.RunMethod("format",Array("%3s",Array(Bit.And(PageData(Pos),0xFF))))} Hex ${JO.RunMethod("format",Array("%02X",Array(PageData(Pos))))} Chr: ${Str}"$
	End If
	DrawHighlights
End Sub

Private Sub DrawHighlights
	CnvHighlights.ClearRect(CnvHighlights.TargetRect)
	For i = 0 To 3
		For Each HT As HighlightType In Highlights(i)
			CnvHighlights.DrawRect(HT.Rect,HT.HighlightColor,True,1)
		Next
	Next
End Sub

Private Sub GetSelectedData As String
	Dim Sb As StringBuilder
	Sb.Initialize
	Dim Jo As JavaObject = ""											'ignore
	
	For Each HT As HighlightType In Highlights(3)
		If HT.HType = "Selected" Then
			Sb.Append(",")
			Sb.Append($"0x${Jo.RunMethod("format",Array("%02X",Array(HT.Data)))}"$)
		End If
	Next
	
	If Sb.Length > 1 Then
		Return Sb.ToString.SubString(1)
	Else
		Return ""
	End If
End Sub



Private Sub HexViewBG_MousePressed (EventData As MouseEvent)
	HexViewBG.RequestFocus
	RemoveHighlights("All","")
	Dim Line As Int = Floor(EventData.Y / LineHeight) - HeaderLines
	Dim Column As Int = Floor(EventData.X - ColumnStart(3) * CharWidth) / CharWidth
	Dim Pos As Int
	Pos = Line * 16 + Column
	If Pos > PageData.Length - 1 Then Return
	StartDragPos = Pos
End Sub

Private Sub HexViewBG_MouseDragged (EventData As MouseEvent)
	Dim Y As Double = EventData.Y
	RemoveHighlights("All","")
	DrawHighlights

	If Y < 0 Or Y > (PageLength + HeaderLines + 1 ) * LineHeight Then Return
	
	Dim Pos As Int
	
	Select True
		Case EventData.X >= ColumnStart(3) * CharWidth And EventData.X <= (ColumnStart(3) + ColumnWidths(3)) * CharWidth
			
			Dim Line As Int = Floor(EventData.Y / LineHeight) - HeaderLines
			Dim Column As Int = Floor(EventData.X - ColumnStart(3) * CharWidth) / CharWidth
			Pos = Line * 16 + Column
			If Pos > PageData.Length - 1 Then Return
			
		
			For i = Min(StartDragPos,Pos) To Max(StartDragPos,Pos)
				
				Line = Floor(i / 16)
				Column = i Mod 16
				
				Dim HT As HighlightType
				HT.Initialize
				
				HT.HType = "Selected"
				HT.Rect.Top = (Line + HeaderLines) * LineHeight
				HT.Rect.Bottom = HT.Rect.Top + LineHeight
				HT.Rect.Left = (ColumnStart(3) + Column) * CharWidth
				HT.Rect.Width = CharWidth
				If i < Max(StartDragPos,Pos) Then HT.Rect.Width = CharWidth + 2
				HT.HighlightColor = mSelectedHighlightColor
				
				Dim SHT As HighlightType
				SHT.Initialize
				Dim Left As Float
				Dim HighlightIndex As Int
				If Column < 8 Then
					Left = (ColumnStart(1) + Column * 2) * CharWidth
					HighlightIndex = 1
				Else
					Left = (ColumnStart(2) + (Column - 8) * 2) * CharWidth
					HighlightIndex = 2
				End If
				SHT.Rect.Initialize(Left,HT.Rect.Top,Left + CharWidth * 2,HT.Rect.Bottom)
				If i < Max(StartDragPos,Pos) Then SHT.Rect.Width = SHT.Rect.Width + 2
				SHT.HighlightColor = mFollowingSelectedHighlightColor
				SHT.HType = "Selected"
				Highlights(3).Add(HT)
				Highlights(HighlightIndex).Add(SHT)
				
				If i > -1 And i < PageData.Length Then
					HT.Data = PageData(i)
				End If
			Next
			
		Case EventData.X >= ColumnStart(0) * CharWidth And EventData.X <= (ColumnStart(0) + ColumnWidths(0)) * CharWidth
			Return
		Case Else
			Return
	End Select
	
	DrawHighlights
	
	If FindForm.IsInitialized And FindForm.IsVisisble Then 
		lvFind.Items.Clear
		lblFindInfo.Text = ""
		TFString.Text = ""
		tfOffset.Text = ""
		TFChr.Text = GetSelectedData
	End If

End Sub

Public Sub AddData(Data() As Byte,Reset As Boolean)
	
	CurrentFileDir = ""
	CurrentFileName = ""
	CurrentOffset = 0
	
	If Reset Then
		DataStore = HexV_Utils.CopyRange(Data,0,Data.Length)
	Else
		DataStore = HexV_Utils.JoinBytes(Array(DataStore,Data))
	End If
	
	SetScrollbar1Metrics(Ceil(DataStore.Length / 16))
	ReadData(0)
	
End Sub

Public Sub Clear
	AddData(Array As Byte(),True)
End Sub

Public Sub LoadFile(FileDir As String, Filename As String)
	
	If File.Exists(FileDir,Filename) = False Then 
		CurrentFileDir = ""
		CurrentFileName = ""
		Return
	End If
	
	If FindForm.IsInitialized Then 
		lvFind.Items.Clear
		lblFindInfo.Text = ""
	End If
	RemoveHighlights("All","")
	
	CurrentFileDir = FileDir
	CurrentFileName = Filename
	ReadData(0)
	
End Sub

Private Sub ReadData(value As Double)
	If CurrentFileName = "" Then
		 ReadDatastore(value)
	Else
		RAFReadPage(value)
	End If
End Sub

Private Sub ReadDatastore(StartRow As Int)
	'Ensure we start on a 16 byte boundary
	Dim DataOffset As Int = StartRow * 16
	CurrentOffset = DataOffset
	Dim DataSize As Int = Min(Max(0,PageLength) * 16,DataStore.Length - CurrentOffset)
	Dim PageData(DataSize) As Byte
	PageData = HexV_Utils.CopyRange(DataStore,CurrentOffset,CurrentOffset + DataSize)
	DrawPage

End Sub

Private Sub SetScrollbar1Metrics(MaxRows As Int)
	Scrollbar1.SetMax(Max(0,MaxRows - PageLength))
	Scrollbar1.SetVisibleAmount(Scrollbar1.GetMax * PageLength / MaxRows)
	Scrollbar1.SetBlockIncrement(PageLength)
End Sub


Private Sub RAFReadPage(StartRow As Int)
	If CurrentFileName = "" Then Return
	Dim RAF As RandomAccessFile
	RAF.Initialize(CurrentFileDir,CurrentFileName,True)
	SetScrollbar1Metrics(Ceil(RAF.Size / 16))
	Dim FileOffset As Int = StartRow * 16
	CurrentOffset = FileOffset
	Dim DataSize As Int = Min(Max(0,PageLength) * 16,RAF.Size - CurrentOffset)
	Dim PageData(DataSize) As Byte
	RAF.ReadBytes(PageData,0,DataSize,CurrentOffset)
	RAF.Close
	DrawPage

End Sub

Private Sub DrawPage
	
	Cnv.ClearRect(Cnv.TargetRect)
	DataStartX = CharWidth
	Dim X As Double
	Dim Y As Double = (1 + HeaderLines) * LineHeight
	
	If mShowHeader Then
		
		Dim R As B4XRect
		R.Initialize(0,0,Cnv.TargetRect.Width,(ReservedHeaderLines) * LineHeight)
		Cnv.DrawRect(R,mHeaderBackgroundColor,True,1)
		Cnv.DrawRect(R,XUI.Color_Black,False,1)
		
		Dim FontB As B4XFont = XUI.CreateFont(fx.CreateFont(mFont.ToNativeFont.FamilyName,mFont.Size,True,False),mFont.Size)
		
		X = (ColumnStart(0) + (ColumnStart(1) - ColumnStart(0)) * CharWidth) / 2
		Y = R.Bottom - (LineHeight / 4) * 3
		Cnv.DrawText("Offset",X,Y,FontB,mHeaderTextColor,"CENTER")
		
		X = CharWidth * (ColumnStart(1) + 1)
		Dim JO As JavaObject = ""													'Ignore
		Dim Header() As Int = Array As Int(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)
		For i = 0 To 7
			Dim Out As String = JO.RunMethod("format",Array("%1X",Array(Header(i))))
			For j = 0 To Out.Length - 1
				Cnv.DrawText(Out.CharAt(j),X,Y,FontB,mHeaderTextColor,"CENTER")
				X = X + CharWidth * 2
			Next
		Next
	
		X = CharWidth * (ColumnStart(2) + 1)
		For i = 8 To 15
			Dim Out As String = JO.RunMethod("format",Array("%1X",Array(Header(i))))
			For j = 0 To Out.Length - 1
				Cnv.DrawText(Out.CharAt(j),X,Y,FontB,mHeaderTextColor,"CENTER")
				X = X + CharWidth * 2
			Next
		Next
		
		X = CharWidth * ColumnStart(3)
		For i = 0 To 15
			Dim Out As String = JO.RunMethod("format",Array("%1X",Array(Header(i))))
			For j = 0 To Out.Length - 1
				Cnv.DrawText(Out.CharAt(j),X,Y,FontB,mHeaderTextColor,"LEFT")
				X = X + CharWidth
			Next
		Next
		
		Y = (ReservedHeaderLines + 1) * LineHeight
	End If
	
	
	X = DataStartX
	For i = 0 To Min(PageData.Length - 1,PageLength * 16) Step 16
		DrawLine(i + CurrentOffset,X,Y, HexV_Utils.CopyRange(PageData,i,Min(i + 16,PageData.Length)))
		Y = Y + LineHeight
	Next

End Sub

Private Sub DrawLine(Offset As Int, X As Double, Y As Double,Data() As Byte)
	

	Dim JO As JavaObject = ""													'Ignore
	Dim Out As String = JO.RunMethod("format",Array("%08x",Array(Offset)))
	For i = 0 To Out.Length - 1
		Cnv.DrawText(Out.CharAt(i),X,Y,mFont,mTextColor,"LEFT")
		X = X + CharWidth
	Next

	X = X + CharWidth
		
	For i = 0 To Min(7,Data.Length - 1)
		Out = JO.RunMethod("format",Array("%02X",Array(Data(i))))
		For j = 0 To Out.Length - 1
			Cnv.DrawText(Out.CharAt(j),X,Y,mFont,mTextColor,"LEFT")
			X = X + CharWidth
		Next
	Next
	
	For i = i To 7
		Cnv.DrawText("  ",X,Y,mFont,mTextColor,"LEFT")
		X = X + CharWidth * 2
	Next

	Out = " | "
	
	For i = 0 To Out.Length - 1
		Cnv.DrawText(Out.CharAt(i),X,Y,mFont,mTextColor,"LEFT")
		X = X + CharWidth
	Next
	

	For i = 8 To Min(15,Data.Length - 1)
		Out = JO.RunMethod("format",Array("%02X",Array(Data(i))))
		For j = 0 To Out.Length - 1
			Cnv.DrawText(Out.CharAt(j),X,Y,mFont,mTextColor,"LEFT")
			X = X + CharWidth
		Next
	Next
	
	For i = i To 15
		Cnv.DrawText("  ",X,Y,mFont,mTextColor,"LEFT")
		X = X + CharWidth * 2
	Next

	
	X = X + CharWidth
	
	For i = 0 To Data.Length - 1
		Dim C As Byte = Data(i)
		If C < 128 And C > 31 Then
			Cnv.DrawText(Chr(C),X,Y,mFont,mTextColor,"LEFT")
			X = X + CharWidth
		Else
			Cnv.DrawText("·",X,Y,mFont,mTextColor,"LEFT")
			X = X + CharWidth
		End If
	Next
		
End Sub

Private Sub Scrollbar1_ValueChanged(Value As Double)
	If Scrollbar1KeepFindHighlights Then
		RemoveHighlights("Highlight","")
		Scrollbar1KeepFindHighlights = False
	Else
		RemoveHighlights("All","")
	End If
	
'	Value = Min(Value,Scrollbar1.GetMax - PageLength + 1)
	ReadData(Value)
End Sub

#Region Options
Public Sub setFont(NewFont As Font)
	mFont = XUI.CreateFont(NewFont,NewFont.Size)
	LineWidth = Cnv.MeasureText(GetChars(ColumnCount,"%"),mFont).Width
	CharWidth = LineWidth / ColumnCount
	HexViewBG_ResizeDo(HexViewBG.Width,HexViewBG.Height)
End Sub

Public Sub getFont As Font
	Return mFont
End Sub

Public Sub getHeaderTextColor As Paint
	Return fx.Colors.From32Bit(mHeaderTextColor)
End Sub

Public Sub setHeaderTextColor(HeaderTextColor As Paint)
	mHeaderTextColor = XUI.PaintOrColorToColor(HeaderTextColor)
	DrawPage
End Sub

Public Sub getHeaderBackgroundColor As Paint
	Return fx.Colors.From32Bit(mHeaderBackgroundColor)
End Sub

Public Sub setHeaderBackgroundColor(HeaderBackgroundColor As Paint)
	mHeaderBackgroundColor = XUI.PaintOrColorToColor(HeaderBackgroundColor)
End Sub

Public Sub getHighlightColor As Paint
	Return fx.Colors.From32Bit(mHighlightColor)
End Sub

Public Sub setHighlightColor(HighlightColor As Paint)
	mHighlightColor = XUI.PaintOrColorToColor(HighlightColor)
End Sub

Public Sub getFollowingHighlightColor As Paint
	Return fx.Colors.From32Bit(mFollowingHighlightColor)
End Sub

Public Sub setFollowingHighlightColor(FollowingHighlightColor As Paint)
	mFollowingHighlightColor = XUI.PaintOrColorToColor(FollowingHighlightColor)
End Sub

Public Sub getFindHighlightColor As Paint
	Return fx.Colors.From32Bit(mFindHighlightColor)
End Sub

Public Sub setFindHighlightColor(FindHighlightColor As Paint)
	mFindHighlightColor = XUI.PaintOrColorToColor(FindHighlightColor)
End Sub

Public Sub getFollowingFindHighlightColor As Paint
	Return fx.Colors.From32Bit(mFollowingFindHighlightColor)
End Sub

Public Sub setFollowingFindHighlightColor(FollowingFindHighlightColor As Paint)
	mFollowingFindHighlightColor = XUI.PaintOrColorToColor(FollowingFindHighlightColor)
End Sub

Public Sub getSelectedHighlightColor As Paint
	Return fx.Colors.From32Bit( mSelectedHighlightColor)
End Sub

Public Sub setSelectedHighlightColor(SelectedHighlightColor As Paint)
	mSelectedHighlightColor = XUI.PaintOrColorToColor(SelectedHighlightColor)
End Sub

Public Sub getFollowingSelectedHighlightColor As Paint
	Return fx.Colors.From32Bit(mFollowingSelectedHighlightColor)
End Sub

Public Sub setFollowingSelectedHighlightColor(FollowingSelectedHighlightColor As Paint)
	mFollowingSelectedHighlightColor = XUI.PaintOrColorToColor(FollowingSelectedHighlightColor)
End Sub

Public Sub getShowHeader As Boolean
	Return mShowHeader
End Sub

Public Sub setShowHeader(ShowHeader As Boolean)
	mShowHeader = ShowHeader
	HexViewBG_ResizeDo(HexViewBG.Width,HexViewBG.Height)
End Sub

Public Sub getTextColor As Paint
	Return fx.Colors.From32Bit(mTextColor)
End Sub

Public Sub setTextColor(TextColor As Paint)
	mTextColor = XUI.PaintOrColorToColor(TextColor)
	DrawPage
End Sub

Public Sub setBackgroundColor(BGColor As Paint)
	HexViewBG.Color = XUI.PaintOrColorToColor(BGColor)
End Sub

Public Sub getBackgroundColor As Paint
	Return fx.Colors.From32Bit(HexViewBG.Color)
End Sub

Public Sub getMaxResults As Int
	Return mMaxResults
End Sub

Public Sub setMaxResults(MaxResults As Int)
	mMaxResults = MaxResults
End Sub
#End Region Options

#Region Find

Public Sub Interrupt
	FindInterrupt = True
End Sub
Public Sub Find(B() As Byte) As ResumableSub
	FindInterrupt = False
	FindTargetBytes = HexV_Utils.CopyRange(B,0,B.Length)
	Dim CurrentFindType As FindType = CreateFindType(-1)
	FoundList.Clear
	
	If CurrentFileName <> "" Then
		Wait For (FindInFile(FindTargetBytes)) Complete (Resp As String)
	Else
		Wait for (FindInStore(FindTargetBytes)) Complete (Resp As String)
	End If
	Return Resp
End Sub

Public Sub FindDo(TargetBytes() As Byte, Data() As Byte, ReadDataLength As Int) As ResumableSub
	Dim Index As Int
	For Index = 0 To Data.Length - 1
		If Data(Index) = TargetBytes(CurrentFindType.TargetIndex) Then
			If CurrentFindType.TargetIndex = TargetBytes.Length - 1 Then
				CurrentFindType.Index = ReadDataLength + Index - (TargetBytes.Length - 1)
				FoundList.Add(CurrentFindType)
				Dim CurrentFindType As FindType = CreateFindType(-1)
			Else
				CurrentFindType.TargetIndex = CurrentFindType.TargetIndex + 1
			End If
		Else
			CurrentFindType.Index = -1
			CurrentFindType.TargetIndex = 0
			'Could be the start of a new match
			If Data(Index) = TargetBytes(CurrentFindType.TargetIndex) Then
				If CurrentFindType.TargetIndex = TargetBytes.Length - 1 Then
					CurrentFindType.Index = ReadDataLength + Index - (TargetBytes.Length - 1)
					FoundList.Add(CurrentFindType)
					Dim CurrentFindType As FindType = CreateFindType(-1)
				Else
					CurrentFindType.TargetIndex = CurrentFindType.TargetIndex + 1
				End If
			End If
		End If
	Next

	Return ""
End Sub

Private Sub FindInStore(TargetBytes() As Byte) As ResumableSub
	Dim DataSize As Int = 2048
	Dim Offset As Int
	Dim ReadDataLength As Int = 0
	For Offset = 0 To DataStore.Length - 1 Step DataSize
		Dim TDS As Int = Min(DataSize,DataStore.Length - Offset)
		Dim Data(TDS) As Byte
		Data = HexV_Utils.CopyRange(DataStore,Offset,Offset + TDS)
		FindDo(TargetBytes,Data,ReadDataLength)
		ReadDataLength = ReadDataLength + TDS
		UpdateProgress(ReadDataLength / DataStore.Length)
		Sleep(0)
		If FindInterrupt Then Exit
	Next
	
	Return ""
End Sub

Private Sub FindInFile(TargetBytes() As Byte) As ResumableSub
	
	Dim DataSize As Int = 2048
	Dim Offset As Int
	Dim RAF As RandomAccessFile
	RAF.Initialize(CurrentFileDir,CurrentFileName,True)
	Dim ReadDataLength As Int = 0
	For Offset = 0 To RAF.Size - 1 Step DataSize
		Dim TDS As Int = Min(DataSize,RAF.Size - ReadDataLength)
		Dim Data(TDS) As Byte
		RAF.ReadBytes(Data,0,Data.Length,Offset)
		FindDo(TargetBytes,Data,ReadDataLength)
		ReadDataLength = ReadDataLength + TDS
		UpdateProgress(ReadDataLength / RAF.Size)
		Sleep(0)
		If FindInterrupt Then Exit
	Next
	RAF.Close
	
	Return ""
End Sub


Public Sub HighlightFound(FI As FindType,TargetBytes() As Byte)
	RemoveHighlights("All","")
	Scrollbar1KeepFindHighlights = True
	Dim StartLine As Int = Floor(Floor(FI.Index / 16) / PageLength) * PageLength
	If StartLine > Scrollbar1.GetMax Then StartLine = Scrollbar1.GetMax
	Scrollbar1.SetValue(StartLine)
	
	For i = 0 To TargetBytes.Length - 1
		
		Dim Column As Int = (FI.Index + i) Mod 16
		Dim Line As Int =  Floor((FI.Index + i) / 16) - StartLine
	
		Dim HT As HighlightType
		HT.Initialize
		Dim Top As Float = (HeaderLines + Line) * LineHeight
		HT.Rect.Initialize(0,Top,10, Top + LineHeight)
		HT.HType = "Find"
		HT.Rect.Left = (ColumnStart(3) + Column) * CharWidth
		If i = TargetBytes.Length - 1 Then
			HT.Rect.Width = CharWidth
		Else
			HT.Rect.Width = CharWidth + 2
		End If
		HT.HighlightColor = mFindHighlightColor
		Highlights(3).Add(HT)
			
		Dim SHT As HighlightType
		SHT.Initialize
		Dim Left As Float
		Dim HighlightIndex As Int
		If Column < 8 Then
			Left = (ColumnStart(1) + Column * 2) * CharWidth
			HighlightIndex = 1
		Else
			Left = (ColumnStart(2) + (Column - 8) * 2) * CharWidth
			HighlightIndex = 2
		End If
		SHT.Rect.Initialize(Left,HT.Rect.Top,Left + CharWidth * 2,HT.Rect.Bottom)
		If i < TargetBytes.Length - 1 Then
			SHT.Rect.Width = SHT.Rect.Width + 2
		End If
		SHT.HighlightColor = mFollowingFindHighlightColor
		SHT.HType = "Find"
		Highlights(HighlightIndex).Add(SHT)
	Next
	DrawHighlights
End Sub
#End Region Find
#Region Utils




Private Sub GetChars(Count As Int,Ch As String) As String
	Dim SB As StringBuilder
	SB.Initialize
	For i = 0 To Count - 1
		SB.Append(Ch)
	Next
	Return SB.ToString
End Sub

'Parent - The Node that ontains a Scrollbar1 i.e. ListView, TableView etc.
'Orientation - can be VERTICAL, HORIZONTAL or BOTH
'Size - The required width for a VERTICAl Scrollbar1 or height for a HORIZONTAL scroll bar
'Hide - Will make the Scrollbar1 size = 1 and transparent
Public Sub SetScrollbar1(Parent As JavaObject, Orientation As String, Size As Double, Hide As Boolean)
	'Get a Set that contains the Scrollbar1s attached to the parent and convert it to an array
	Dim Arr() As Object = Parent.RunMethodJO("lookupAll",Array(".scroll-bar")).RunMethod("toArray",Null)

	For Each N As Node In Arr

		'Check this object is a scrolbar
		If GetType(N) = "com.sun.javafx.scene.control.skin.VirtualScrollbar1" Or GetType(N) = "javafx.scene.control.Scrollbar1" Then
			Dim SB As JavaObject = N

			'Get the orientation of the Scrollbar1 as a string
			Dim BarOrientation As String = SB.RunMethodJO("getOrientation",Null).RunMethod("toString",Null)

			'Required Orientation is VERTICAL or BOTH
			If BarOrientation = "VERTICAL" And (Orientation  = BarOrientation Or Orientation = "BOTH") Then
				If Hide Then
					N.PrefWidth = 1
					N.Alpha = 0
				Else
					N.PrefWidth = Size
				End If
			End If

			'Required Orientation is HORIZONTAL or BOTH
			If BarOrientation = "HORIZONTAL" And (Orientation = BarOrientation Or Orientation = "BOTH") Then
				If Hide Then
					N.PrefHeight = 1
					N.Alpha = 0
				Else
					N.PrefHeight = Size
				End If
			End If
		End If
 
	Next
End Sub

#End Region Utils

Public Sub CreateFindType (Index As Int) As FindType
	Dim t1 As FindType
	t1.Initialize
	t1.Index = Index
	t1.TargetIndex = 0
	Return t1
End Sub

#Region Find
Sub btnDone_Click
	RemoveHighlights("All","")
	FindForm.Hide
End Sub

Sub btnFind_Click
	pnNav.Visible = False
	RemoveHighlights("All","")
	If TFChr.Text <> "" Then
		lvFind.Items.Clear
		lblFindInfo.Text = ""
		Dim B() As Byte = ParseChr(TFChr.Text)
		If B.Length = 0 Then
			lblFindInfo.TextColor = fx.Colors.Red
			lblFindInfo.Text = "Invalid search terms"
			Return
		End If

	Else
		lvFind.Items.Clear
		lblFindInfo.Text = ""
		If TFString.Text = "" Then Return
		Dim B() As Byte = TFString.Text.GetBytes("UTF8")
	End If
	
	UpdateProgress(0)
	Wait For (Find(B)) Complete (Resp As String)
	Dim Msg As String
	If FindInterrupt Then
		Msg = "Process interrupted : "
	Else
		Msg = Msg & $"Found ${FoundList.Size} items"$
	End If
	
	If FindInterrupt = False  Then
		LoadResults(0)
		If FoundList.Size > mMaxResults Then
			pnNav.Visible = True
			lblFoundCount.Text = $" / $1.0{Floor(FoundList.Size/ mMaxResults)}"$
			NumberSpinnerCV1.MinValue = 0
			NumberSpinnerCV1.MaxValue = Floor(FoundList.Size / mMaxResults)
			NumberSpinnerCV1.Value = 0
		End If

	End If
	
	If lvFind.Items.Size > 0 Then lvFind.SelectedIndex = 0
	
End Sub

Private Sub NumberSpinnerCV1_ValueChanged(Value As Double,AutoUpdate As Boolean)
	LoadResults(Value * mMaxResults)
End Sub

Private Sub LoadResults(StartIndex As Int)
	lvFind.Items.Clear
	For i = StartIndex To Min(StartIndex + mMaxResults - 1, FoundList.Size - 1)
		Dim Fi As FindType = FoundList.Get(i)
		Dim JO As JavaObject = ""													'Ignore
		Dim Out As String = JO.RunMethod("format",Array("%08x",Array(Fi.Index)))
		Dim L As Label
		L.Initialize("")
		L.Text = $"${i + 1}: ${Fi.Index} (${Out})"$
		L.tag = Fi
		lvFind.Items.Add(L)
	Next
	Dim Msg As String
	Msg = Msg & $"Found ${FoundList.Size} items showing  ${StartIndex + 1} - $1.0{Min(FoundList.Size, StartIndex + mMaxResults)}"$
	lblFindInfo.TextColor = fx.Colors.Black
	lblFindInfo.Text = Msg
End Sub

Private Sub btnStop_Click
	Interrupt
End Sub

Private Sub lvFind_SelectedIndexChanged(Index As Int)
	If Index < 0 Then Return
	Dim Lbl As Label = lvFind.Items.Get(Index)
	HighlightFound(Lbl.Tag,FindTargetBytes)
End Sub
Sub UpdateProgress(Value As Double)
	pbFind.Progress = Value
End Sub

Private Sub ParseChr(Text As String) As Byte()
	Dim B() As Byte
	If Text = "" Then Return B
	Dim L As List
	L.Initialize
	Try
		Dim Val As Byte
		For Each S As String In Regex.Split(",",Text)
			If S.ToLowerCase.StartsWith("0x") Then
				Val = Bit.ParseInt(S.SubString(2),16)
			Else
				If IsNumber(S) And Floor(S) = S Then
					Val = S
				Else
					Return Array As Byte()
				End If
			End If
			L.Add(Array As Byte(Val))
		Next
		B = HexV_Utils.JoinBytes(L)
	Catch
		Log(LastException)
		Return Array As Byte()
	End Try
	Return B
End Sub


#End Region Find

Sub TFString_TextChanged (Old As String, New As String)
	lblFindInfo.Text = ""
End Sub

Sub TFString_Action
	btnFind_Click
End Sub

Sub TFChr_Action
	btnFind_Click
End Sub


Sub TFChr_TextChanged (Old As String, New As String)
	lblFindInfo.Text = ""
End Sub

Sub TFChr_FocusChanged (HasFocus As Boolean)
	If HasFocus Then
		lvFind.Items.Clear
		TFString.Text = ""
		tfOffset.Text = ""
	End If
End Sub

Sub TFString_FocusChanged (HasFocus As Boolean)
	If HasFocus Then
		lvFind.Items.Clear
		TFChr.Text = ""
		tfOffset.Text = ""
	End If
End Sub

Sub tfOffset_FocusChanged (HasFocus As Boolean)
	If HasFocus Then
		lvFind.Items.Clear
		TFString.Text = ""
		TFChr.Text = ""
	End If
End Sub

Sub tfOffset_Action
	RemoveHighlights("All","")
	If tfOffset.Text = "" Then Return
	Dim Offset As Int
	If tfOffset.Text.ToLowerCase.StartsWith("0x") Then
		Try
		Offset = Bit.ParseInt(tfOffset.Text.SubString(2),16)
		Catch
			lblFindInfo.TextColor = fx.Colors.Red
			lblFindInfo.Text = "Must be a whole number or Hex value"
		End Try
	else If IsNumber(tfOffset.Text) = False Or Floor(tfOffset.Text) <> tfOffset.Text Then
		lblFindInfo.TextColor = fx.Colors.Red
		lblFindInfo.Text = "Must be a whole number or Hex value"
		Return
	Else
		Offset = tfOffset.Text
	End If
	Dim Fi As FindType = CreateFindType(Offset)
	HighlightFound(Fi,Array As Byte(0))
End Sub