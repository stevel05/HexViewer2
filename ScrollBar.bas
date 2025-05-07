B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=5.82
@EndOfDesignText@
#Event: ValueChanged(Value As Double)
#Event: ValueChanged2(Sender As Object,Value As Double)

#IgnoreWarnings:12
'Class Module
Sub Class_Globals
	'Private fx As JFX ' Uncomment if required. For B4j only
	Private TJO As JavaObject
	Private mCallBack As Object
	Private mEventName As String
End Sub

'Creates a new horizontal ScrollBar (ie getOrientation() == Orientation.HORIZONTAL).
Public Sub Initialize
	'If a JavaObject has been passed, you may need to create it here and remove the parameter
	TJO.InitializeNewInstance("javafx.scene.control.ScrollBar",Null)
End Sub

'Adjusts the value property by blockIncrement.
Public Sub AdjustValue(Position As Double)
	TJO.RunMethod("adjustValue",Array As Object(Position))
End Sub
'Create a new instance of the default skin for this control.
Private Sub CreateDefaultSkin As JavaObject
	Return TJO.RunMethod("createDefaultSkin",Null)
End Sub
'Decrements the value of the ScrollBar by the unitIncrement
Public Sub Decrement
	TJO.RunMethod("decrement",Null)
End Sub
'This method is called by the assistive technology to request the action indicated by the argument should be executed.
Public Sub ExecuteAccessibleAction(Action As JavaObject, Parameters() As Object)
	TJO.RunMethod("executeAccessibleAction",Array As Object(Action, Parameters))
End Sub
'Gets the value of the property blockIncrement.
Public Sub GetBlockIncrement As Double
	Return TJO.RunMethod("getBlockIncrement",Null)
End Sub
'
Public Sub GetClassCssMetaData As JavaObject
	Dim TJO1 As JavaObject
	TJO1.InitializeStatic("javafx.scene.control.ScrollBar")
	Return TJO1.RunMethod("getClassCssMetaData",Null)
End Sub

'Gets the value of the property max.
Public Sub GetMax As Double
	Return TJO.RunMethod("getMax",Null)
End Sub
'Gets the value of the property min.
Public Sub GetMin As Double
	Return TJO.RunMethod("getMin",Null)
End Sub
'Gets the value of the property orientation.
Public Sub GetOrientation As JavaObject
	Return TJO.RunMethod("getOrientation",Null)
End Sub
'Gets the value of the property unitIncrement.
Public Sub GetUnitIncrement As Double
	Return TJO.RunMethod("getUnitIncrement",Null)
End Sub
'Gets the value of the property value.
Public Sub GetValue As Double
	Return TJO.RunMethod("getValue",Null)
End Sub
'Gets the value of the property visibleAmount.
Public Sub GetVisibleAmount As Double
	Return TJO.RunMethod("getVisibleAmount",Null)
End Sub
'Increments the value of the ScrollBar by the unitIncrement
Public Sub Increment
	TJO.RunMethod("increment",Null)
End Sub
'* Accessibility handling * *
Public Sub QueryAccessibleAttribute(Attribute As JavaObject, Parameters() As Object) As Object
	Return TJO.RunMethod("queryAccessibleAttribute",Array As Object(Attribute, Parameters))
End Sub
'Sets the value of the property blockIncrement.
Public Sub SetBlockIncrement(Value As Double)
	TJO.RunMethod("setBlockIncrement",Array As Object(Value))
End Sub
'Sets the value of the property max.
Public Sub SetMax(Value As Double)
	TJO.RunMethod("setMax",Array As Object(Value))
End Sub
'Sets the value of the property min.
Public Sub SetMin(Value As Double)
	TJO.RunMethod("setMin",Array As Object(Value))
End Sub
'Sets the value of the property orientation.
Public Sub SetOrientation(Value As String)
	TJO.RunMethod("setOrientation",Array As Object(Value))
End Sub
'Sets the value of the property unitIncrement.
Public Sub SetUnitIncrement(Value As Double)
	TJO.RunMethod("setUnitIncrement",Array As Object(Value))
End Sub
'Sets the value of the property value.
Public Sub SetValue(Value As Double)
	TJO.RunMethod("setValue",Array As Object(Value))
End Sub
'Sets the value of the property visibleAmount.
Public Sub SetVisibleAmount(Value As Double)
	TJO.RunMethod("setVisibleAmount",Array As Object(Value))
End Sub

Public Sub AsNode As Node
	Return TJO
End Sub

Public Sub AsB4xView As B4XView
	Return TJO
End Sub

'Get the unwrapped object
Public Sub GetObject As Object
	Return TJO
End Sub

'Get the unwrapped object As a JavaObject
Public Sub GetObjectJO As JavaObject
	Return TJO
End Sub
'Comment if not needed

'Set the underlying Object, must be of correct type
Public Sub SetObject(Obj As Object)
	TJO = Obj
End Sub

'Set the Tag for this object
Public Sub SetTag(Tag As Object)
	TJO.RunMethod("setUserData",Array(Tag))
End Sub

'Get the Tag for this object
Public Sub GetTag As Object
	Dim Tag As Object = TJO.RunMethod("getUserData",Null)
	If Tag = Null Then Tag = ""
	Return Tag
End Sub

'Set a value listener on this scrollbar
Public Sub SetValueListener(CallBack As Object,EventName As String)
	If SubExists(CallBack,EventName & "_ValueChanged") = False And SubExists(CallBack,EventName & "_ValueChanged2") = False Then Return
	mCallBack = CallBack
	mEventName = EventName
	Dim O As Object = TJO.CreateEventFromUI("javafx.beans.value.ChangeListener","ValueChanged",Null)
	Dim ValProp As JavaObject = TJO.RunMethod("valueProperty",Null)
	ValProp.RunMethod("addListener",Array(O))
End Sub

Private Sub ValueChanged_Event (MethodName As String, Args() As Object)
	Dim Prop As JavaObject = Args(0)
	If SubExists(mCallBack,mEventName & "_ValueChanged") Then CallSubDelayed2(mCallBack,mEventName & "_ValueChanged",Prop.RunMethod("getValue",Null))
	If SubExists(mCallBack,mEventName & "_ValueChanged2") Then CallSubDelayed3(mCallBack,mEventName & "_ValueChanged2",Me,Prop.RunMethod("getValue",Null))
End Sub

