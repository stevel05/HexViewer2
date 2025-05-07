B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8
@EndOfDesignText@
#Event: KeyPressed(KEvt As KeyEvent)
#Event: KeyTyped(KEvt As KeyEvent)
#Event: KeyReleased(KEvt As KeyEvent)

Sub Class_Globals
	Private fx As JFX
	Private JO As JavaObject
	Private EventMap As Map
	Type EventType (Module As Object,Eventname As String, EventType As Object)
	
	'Constants / Fields are defined here and initialized in Sub UpdateConstants
	'Common supertype for all key event types.
	Public ANY As JavaObject
	'KEY_PRESSED and KEY_RELEASED events which do not map to a valid Unicode character use this for the keyChar value.
	Public CHAR_UNDEFINED As String
	'This event occurs when a key has been pressed.
	Public KEY_PRESSED As JavaObject
	'This event occurs when a key has been released.
	Public KEY_RELEASED As JavaObject
	'This event occurs when a character-generating key was typed (pressed and released).
	Public KEY_TYPED As JavaObject
	Private IInitialized As Boolean

End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	If IInitialized Then Return
	EventMap.Initialize
	JO.InitializeStatic("javafx.scene.input.KeyEvent")
	UpdateConstants
	IInitialized = True
End Sub

Private Sub UpdateConstants
	ANY = JO.GetField("ANY")
	CHAR_UNDEFINED = JO.GetField("CHAR_UNDEFINED")
	KEY_PRESSED = JO.GetField("KEY_PRESSED")
	KEY_RELEASED = JO.GetField("KEY_RELEASED")
	KEY_TYPED = JO.GetField("KEY_TYPED")
End Sub

Public Sub IsInitialized As Boolean
	Return IInitialized
End Sub

'***************************************************************************************************************
'Key event subs
'***************************************************************************************************************

'Create a keyevent listener on the given Node for the given eventtype
'Node : the node on which to set the listener
'EventType : The type of the event to listen for (One of the KeyEventStatic constants, KEY_PRESSED, KEY_TYPED or KEY_RELEASED).
'EventName :  the JavaObject callback sub which should have the signature :{EventName}_Event(MethodName As String,Args() as Object) As Object
'Event : Pass an event if you want to reuse an already defined event which was previously returned from a call to this sub, or Null if you are adding a new event sub
Public Sub SetKeyEvent(Node As Object, EventType As Object, Module As Object, EventName As String) As Object	'ignore
	If IsInitialized = False Then
		Log("KeyEventHelper is not initialized")
		Return Null
	End If
	
	Dim ThisEvent As Object
	
	Dim TypeName As String
	Select EventType
		Case KEY_PRESSED
			TypeName = "KeyPressed"
		Case KEY_RELEASED
			TypeName = "KeyReleased"
		Case KEY_TYPED
			TypeName = "KeyTyped"
	End Select
	
	If SubExists(Module,EventName & "_" & TypeName) = False Then Return Null
	
	Dim R As Reflector
	R.Target = Node
	R.AddEventFilter(TypeName,"javafx.scene.input.KeyEvent." & EventType)

	
	Dim TTYpe As EventType
	TTYpe.Initialize
	TTYpe.Module = Module
	TTYpe.Eventname = EventName
	TTYpe.EventType = EventType
	
	Dim L As List
	L.Initialize
	L = EventMap.Getdefault(Node,L)
	L.Add(TTYpe)
	EventMap.Put(Node,L)
	
	Return ThisEvent
End Sub

Private Sub KeyPressed_Filter (E As Event)
	If E = Null Then Return
	Dim L As List = EventMap.Get(Sender)
	Dim KE As KeyEvent
	KE.Initialize(E)
	For Each TType As EventType In L
		CallSubDelayed2(TType.Module,TType.Eventname & "_KeyPressed",KE)
	Next
End Sub

Private Sub KeyReleased_Filter (E As Event)
	If E = Null Then Return
	Dim L As List = EventMap.Get(Sender)
	Dim KE As KeyEvent
	KE.Initialize(E)
	For Each TType As EventType In L
		CallSubDelayed2(TType.Module,TType.Eventname & "_KeyReleased",KE)
	Next
End Sub

Private Sub KeyTyped_Filter (E As Event)
	If E = Null Then Return
	Dim L As List = EventMap.Get(Sender)
	Dim KE As KeyEvent
	KE.Initialize(E)
	For Each TType As EventType In L
		CallSubDelayed2(TType.Module,TType.Eventname & "_KeyTyped",KE)
	Next
End Sub

'Remove a keyevent listener from the given Node for the given eventtype
'Node : the node from which to remove the listener
'EventType : The type of the event to remove (One of the KeyEventStatic constants, KEY_PRESSED, KEY_TYPED or KEY_RELEASED).
'Event : the event returned from a previous call to SetKeyEvent
Public Sub RemoveKeyEvent(Node As JavaObject, Module As Object,EventName As String,EventType As Object, Event As Object)						'ignore
	Dim TypeName As String
	Select EventType
		Case KEY_PRESSED
			TypeName = "KeyPressed"
		Case KEY_RELEASED
			TypeName = "KeyReleased"
		Case KEY_TYPED
			TypeName = "KeyTyped"
	End Select
	Dim L As List
	L.Initialize
	L = EventMap.GetDefault(TypeName,L)
	Dim i As Int = 0
	For Each TType As EventType In L
		If TType.Module = Module And TType.Eventname = EventName And TType.EventType = EventType Then
			Node.RunMethod("removeEventHandler",Array(EventType,Event))
			L.RemoveAt(I)
			Exit
		End If
		i = i + 1
	Next
	If L.Size = 0 Then EventMap.Remove(TypeName)
End Sub

'***************************************************************************************************************