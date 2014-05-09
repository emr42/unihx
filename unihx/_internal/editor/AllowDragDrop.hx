package unihx._internal.editor;
import unityengine.*;
import unityeditor.*;
using StringTools;

@:meta(UnityEditor.CustomEditor(typeof(UnityEngine.Transform)))
@:meta(UnityEditor.CanEditMultipleObjects)
@:nativeGen
@:native('AllowDragDrop')
class AllowDragDrop extends Editor
{
	private function OnEnable()
	{
		Repaint();
	}

	inline private function tgt():Transform
	{
		return cast this.target;
	}

	@:overload override public function OnInspectorGUI()
	{
		switch(Event.current.type)
		{
			case DragUpdated | DragExited if (AssetDatabase.GetAssetPath(DragAndDrop.objectReferences[0]).endsWith('.hx')):
				trace("HIEAR");
				DragAndDrop.visualMode = Link;
				Event.current.Use();

			case DragPerform if (AssetDatabase.GetAssetPath(DragAndDrop.objectReferences[0]).endsWith('.hx')):
				DragAndDrop.visualMode = Link;
				DragAndDrop.AcceptDrag();
				Event.current.Use();
				tgt().gameObject.AddComponent(DragAndDrop.objectReferences[0].name);
				trace("adding ",DragAndDrop.objectReferences[0].name);
			case _:
				// trace(Event.current.type);
		}
	}
}
