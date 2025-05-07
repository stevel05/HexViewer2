B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=5.9
@EndOfDesignText@
#Event:ValueChanged(Value As Double,AutoUpdate As Boolean)
#DesignerProperty: Key: MinValue, DisplayName: Min Value, FieldType: Int, DefaultValue: 0, Description: Minimum value
#DesignerProperty: Key: InitValue, DisplayName: Initial Value, FieldType: Int, DefaultValue: 0, Description: Initial value
#DesignerProperty: Key: MaxValue, DisplayName: Max Value, FieldType: Int, DefaultValue: 100, Description: Maximum value
#DesignerProperty: Key: MinFractions, DisplayName: Min Fractions, FieldType: Int, DefaultValue: 0, Description: Minimum Fractions
#DesignerProperty: Key: MaxFractions, DisplayName: Max Fractions, FieldType: Int, DefaultValue: 0, Description: Maximum Fractions
#DesignerProperty: Key: MinIntegers, DisplayName: Min Integers, FieldType: Int, DefaultValue: 1, Description: Minimum Integers
#DesignerProperty: Key: Increment, DisplayName: Increment, FieldType: Float, DefaultValue: 1, Description: Increment
#DesignerProperty: Key: Grouping, DisplayName: Grouping, FieldType: Boolean, DefaultValue: False, Description: Grouping
'Class module
Sub Class_Globals

	Private btnUp,btnDown As B4XView
	Private tf As B4XView
	
	Private mBase As B4XView
	Private mMinInts,mMaxFracs,mMinFracs As Int
	Private mMaxVal,mMinVal As Double
	Private TickIncrement As Double
	Private Timer1 As Timer
	Private TimerStartInterval As Int = 2000
	Private mIncrement As Double
	Private AutoUpdate,ManualUpdate As Boolean
	Private mModule As Object
	Private mEventName As String
	Private ValidChars As String = "0123456789-."
	Private mGrouping As Boolean
	Private IInitialized As Boolean
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize(Module As Object,EventName As String)

	'Set up the global variables
	mModule = Module
	mEventName = EventName
	
End Sub
Public Sub DesignerCreateView (Base As Object, Lbl As Label, Props As Map)
	mBase = Base
	mMinInts = Props.get("MinIntegers")
	mMaxFracs = Props.get("MaxFractions")
	mGrouping = Props.Get("Grouping")
	mMinFracs = Props.get("MinFractions")
	mIncrement = Props.get("Increment")
	mMinVal = Props.Get("MinValue")
	mMaxVal = Props.Get("MaxValue")
	
	'Initialize the internal views for the spinner

	mBase.LoadLayout("numberspinner")
	Base_Resize(mBase.Width,mBase.Height)
			
	'Set the initial value
	AutoUpdate = True
	setValue(Props.Get("InitValue"))

	mBase.Tag = Me
	
	'Disable focus on the buttons, so it doesn't flash between the text field and buttons
	Dim JO As JavaObject = btnDown
	JO.RunMethod("setFocusTraversable",Array(False))
	JO = btnUp
	JO.RunMethod("setFocusTraversable",Array(False))
	
	'initialize the timer
	Timer1.Initialize("Timer1",TimerStartInterval)
	
	'Create Key pressed and released events so we can capture key presses
	Dim TFJO As JavaObject = tf
	Dim O As Object = TFJO.CreateEvent("javafx.event.EventHandler","TFKeyPressed",False)
	TFJO.RunMethod("setOnKeyPressed",Array(O))
	
	Dim O As Object = TFJO.CreateEvent("javafx.event.EventHandler","TFKeyReleased",False)
	TFJO.RunMethod("setOnKeyReleased",Array(O))
	Dim TFF As TextField = tf
	TFF.Style = TFF.Style &"-fx-alignment:center-right;"
	IInitialized = True
End Sub
#Region Layout Subs
'Set the Layout of the mBase
Public Sub setLayout(Left As Double,Top As Double,Width As Double,Height As Double)
	mBase.Left = Left
	mBase.Top = Top
	mBase.Width = Width
	mBase.Height = Height
End Sub
Private Sub Base_Resize (Width As Double, Height As Double)
	Dim bWidth As Double = (Width/100) * 20
	btnDown.Width = bWidth
	btnDown.Height = Height
	btnUp.Left = bWidth * 4
	btnUp.Width = bWidth
	btnUp.Height = Height
	tf.Left = bWidth
	tf.Width = bWidth * 3
	tf.Height = Height
End Sub
#End Region Layout Subs

#Region Object Specific Subs
'Get the Initialized state of this Object
Public Sub IsInitialized As Boolean
	Return IInitialized
End Sub
'Get the Base of this CustomView
Public Sub GetBase As B4XView
	Return mBase
End Sub

'Get / Set the current Value. Should be between MinVal and MaxVal inclusive (if set)
Sub setValue(Val As Double)
	Dim Text As String
'	Dim LastVal As String = 0
'	If Initialized Then LastVal = getValue
	If mMaxVal = mMinVal Then
		Text = NumberFormat2(mMinVal,mMinInts,mMaxFracs,mMinFracs,mGrouping)
	Else
		Text = NumberFormat2(Min(mMaxVal,Max(mMinVal,Val)),mMinInts,mMinFracs,mMaxFracs,mGrouping)
	End If
	If Text = "-0" Then Text = "0"
	tf.Text = Text
	Dim TFF As TextField = tf
	TFF.SetSelection(tf.Text.Length,tf.Text.Length)
	If AutoUpdate = False Then
		If SubExists(mModule, mEventName & "_ValueChanged") Then CallSubDelayed3(mModule, mEventName & "_ValueChanged",getValue,AutoUpdate)
	End If
End Sub

Sub getValue As Double
	If Not(IsNumber(tf.Text.Replace(",",""))) Then Return 0
	Return  tf.Text.Replace(",","")
End Sub

Private Sub TF_TextChanged (Old As String, New As String)
	If ManualUpdate Then
		ManualUpdate = False
		Return
	End If
	If Not(ValidateText(New.Replace(",",""))) Then
		ManualUpdate = True
		AutoUpdate = True
		setValue(0 & Old.Replace(",",""))
		Return
	End If
	If AutoUpdate = False Then
		If SubExists(mModule, mEventName & "_ValueChanged") Then CallSubDelayed3(mModule, mEventName & "_ValueChanged",getValue,True)
	End If
End Sub

Private Sub TF_Action
	'Validate and Format the entered value
	setValue(getValue)
End Sub
'Get / Set the Maximum values
Sub getMaxValue As Double
	Return mMaxVal
End Sub
Sub setMaxValue(MaxVal As Double)
	mMaxVal = MaxVal
	AutoUpdate = True
	setValue(Min(getValue,mMaxVal))
End Sub
'Get / Set the Minimum values
Sub getMinValue As Double
	Return mMinVal
End Sub
Sub setMinValue(MaxVal As Double)
	mMinVal = MaxVal
	AutoUpdate = True
	setValue(Max(getValue,mMinVal))
End Sub
'Get / set the Increment
Sub setIncrement(Increment As Double)
	mIncrement = Increment
End Sub
Sub getIncrement As Double
	Return mIncrement
End Sub
'Set whether grouping should be displayed
Sub setGrouping(Grouping As Boolean)
	mGrouping = Grouping
	AutoUpdate = True
	setValue(getValue)
End Sub
Sub getGrouping As Boolean
	Return mGrouping
End Sub
'Get / Set the maximum number of decimal places to display
Sub setMaxFractions(MaxFracs As Int)
	mMaxFracs = MaxFracs
	AutoUpdate = True
	setValue(getValue)
End Sub
Sub getMaxFractions As Int
	Return mMaxFracs
End Sub
'Get / Set the minimum number of decimal places to display
Sub setMinFractions(MinFracs As Int)
	mMinFracs = MinFracs
	AutoUpdate = True
	setValue(getValue)
End Sub
Sub getMinFractions As Int
	Return mMinFracs
End Sub
'Get / Set the minimum number of Integers to display
Sub setMinIntegers(MinInts As Int)
	mMinInts= MinInts
	AutoUpdate = True
	setValue(getValue)
End Sub
Sub getMinIntegers As Int
	Return mMinInts
End Sub
Private Sub ValidateText(Text As String) As Boolean
	Dim Valid As Boolean = True
	'Check that all characters are in the ValidChars String
	For i = 0 To Text.Length - 1
		If Not(ValidChars.Contains(Text.CharAt(i))) Then
			'Otherwise return false (Validation failed)
			Valid = False
			Exit
		End If
		'If the text is a '-' then is should only be in position 0
		If Text.CharAt(i) = "-" And i <> 0 Then
			Valid = False
			Exit
		End If
	Next
	'Return the result
	Return Valid
End Sub
Private Sub Timer1_Tick
	If AutoUpdate Then setValue(getValue + TickIncrement)
	'Reduce the timer interval so the scrolling speeds up
	Timer1.Interval = Max(100,Timer1.Interval * 0.5)
End Sub
#End Region Object Specific Subs

#Region Mouse Access Subs
Private Sub btnDown_MousePressed (EventData As MouseEvent)
	Log("BtnDown MousePressed")
	'Set the Textfield non editable so the text cursor is not displayed while scrolling through the values
	Dim JO As JavaObject = tf
	JO.RunMethod("setEditable",Array(False))
	'Set the tick increment with the appropriate sign
	TickIncrement = -mIncrement
	AutoUpdate = True
	'Start the timer
	Timer1.Enabled = True
	'Call the tick sub so the first update is now
	Timer1_Tick
End Sub
Private Sub btnDown_MouseReleased (EventData As MouseEvent)
	'Disable the timer
	Timer1.Enabled = False
	'Reset the initial interval
	Timer1.Interval = TimerStartInterval
	'Re-enable editing so the text cursor shows
	Dim JO As JavaObject = tf
	JO.RunMethod("setEditable",Array(True))
	AutoUpdate = False
	'Do Callbacks if needed
	If SubExists(mModule, mEventName & "_ValueChanged") Then
		Dim Val As Double = tf.Text.Replace(",","")
		CallSubDelayed3(mModule, mEventName & "_ValueChanged",Val,True)
	End If
	'Send the focus to the textfield
	tf.RequestFocus
End Sub
Private Sub btnUp_MousePressed (EventData As MouseEvent)
	Log("BtnUp MousePressed")
	'Set the Textfield non editable so the text cursor is not displayed while scrolling through the values
	Dim JO As JavaObject = tf
	AutoUpdate = True
	JO.RunMethod("setEditable",Array(False))
	'Set the tick increment with the appropriate sign
	TickIncrement = mIncrement
	'Start the timer
	Timer1.Enabled = True
	'Call the tick sub so the first update is now
	Timer1_Tick
End Sub
Private Sub btnUp_MouseReleased (EventData As MouseEvent)
	'Disable the timer
	Timer1.Enabled = False
	'Reset the initial interval
	Timer1.Interval = TimerStartInterval
	'Re-enable editing so the text cursor shows
	Dim JO As JavaObject = tf
	JO.RunMethod("setEditable",Array(True))
	'Do Callbacks if needed
	If SubExists(mModule, mEventName & "_ValueChanged") Then
		Dim Val As Double = tf.Text.Replace(",","")
		CallSubDelayed3(mModule, mEventName & "_ValueChanged",Val,True)
	End If
	AutoUpdate = False
	'Send the focus to the textfield
	tf.RequestFocus
End Sub
#End Region Mouse Access Subs

#Region Keyboard Access Subs
'Enable keyboard access
Private Sub TFKeyPressed_Event(EventName As String,Args() As Object) As Object
	Dim KEvent As Event = Args(0)
	Dim KEventJO As JavaObject = Args(0)
	Dim tKeyCode As JavaObject = KEventJO.RunMethod("getCode",Null)
	Dim KeyName As String = tKeyCode.RunMethod("getName",Null)

	'For the Up and Down Keys
	Select KeyName
		Case "Up"
			'Set the Textfield non editable so the text cursor is not displayed while scrolling through the values
			Dim JO As JavaObject = tf
			JO.RunMethod("setEditable",Array(False))
			AutoUpdate = True
			'Set the tick increment with the appropriate sign
			TickIncrement = mIncrement
			'Start the timer
			Timer1.Enabled = True
			'Call the tick sub so the first update is now
			Timer1_Tick
			'Consume the event
			KEvent.Consume
		Case "Down"
			'Set the Textfield non editable so the text cursor is not displayed while scrolling through the values
			Dim JO As JavaObject = tf
			JO.RunMethod("setEditable",Array(False))
			AutoUpdate = True
			'Set the tick increment with the appropriate sign
			TickIncrement = -mIncrement
			'Start the timer
			Timer1.Enabled = True
			'Call the tick sub so the first update is now
			Timer1_Tick
			'Consume the event
			KEvent.Consume
	End Select
	
	Return False
End Sub
Private Sub TFKeyReleased_Event(EventName As String,Args() As Object) As Object
	Dim KEvent As Event = Args(0)
	Dim KEventJO As JavaObject = Args(0)
	Dim tKeyCode As JavaObject = KEventJO.RunMethod("getCode",Null)
	Dim KeyName As String = tKeyCode.RunMethod("getName",Null)
'	Log(KeyName)
	
	Select KeyName
		Case "Up", "Down"
			'Reset the initial interval
			Timer1.Interval = TimerStartInterval
			'Disable the timer
			Timer1.Enabled = False
			'Re-enable editing so the text cursor shows
			Dim JO As JavaObject = tf
			JO.RunMethod("setEditable",Array(True))
			'Do Callbacks if needed
			
			If SubExists(mModule, mEventName & "_ValueChanged") Then
				Dim Val As Double = tf.Text.Replace(",","")
				CallSubDelayed3(mModule, mEventName & "_ValueChanged",Val,True)
			End If
			'Send the focus to the textfield
			tf.RequestFocus
			'Consume the event
			KEvent.Consume
	End Select
	AutoUpdate = False
	Return False
End Sub
#End Region Keyboard Access Subs

