package unihx.pvt.editor;
import unityengine.*;
import unityeditor.*;
import unihx.pvt.compiler.*;
import haxe.ds.Vector;
import unihx.inspector.*;
using StringTools;
import sys.FileSystem.*;

@:meta(UnityEditor.CustomEditor(typeof(UnityEngine.Object)))
@:nativeGen
@:native('HxInspector')
class HxInspector extends Editor
{
	private var prop:HxmlProps;
	private var scroll:Vector2;

	static var s_helpBox:GUIStyle;
	static var s_entryWarn:GUIStyle;
	static var s_txtWarn:GUIStyle;

	private function OnEnable()
	{
		Repaint();
	}

	public static function HxmlOnGUI(prop:HxmlProps)
	{
		if (s_helpBox == null)
		{
			s_helpBox = new GUIStyle(untyped 'HelpBox');
			s_helpBox.padding = new RectOffset(10,10,10,10);
			s_entryWarn = untyped 'CN EntryWarn';
			s_txtWarn = new GUIStyle(untyped 'CN StatusWarn');
			s_txtWarn.wordWrap = true;
			s_txtWarn.alignment = MiddleLeft;
			s_txtWarn.stretchWidth = true;
		}

		GUI.enabled = true;
		GUILayout.Space(6);
		prop.OnGUI();

		GUILayout.Space(3);
		var buttonLayout = new cs.NativeArray(1);
		buttonLayout[0] = GUILayout.MinHeight(33);
		if (GUILayout.Button("Save",buttonLayout))
		{
			prop.save();
		}
		GUILayout.Space(3);
		if (GUILayout.Button("Reload",buttonLayout))
		{
			prop.reload();
		}
		GUILayout.Space(3);
		if (GUILayout.Button("Force Recompilation",buttonLayout))
		{
			Globals.chain.compile(true);
			unityeditor.AssetDatabase.Refresh();
		}

		var warns = prop.getWarnings();
		if (warns.length > 0)
		{
			GUILayout.Space(15);
			for (w in warns)
			{
				GUILayout.BeginHorizontal(s_helpBox, new cs.NativeArray(0));
				GUILayout.Label('', s_entryWarn, new cs.NativeArray(0));
				GUILayout.Label(w.msg, s_txtWarn, new cs.NativeArray(0));
				GUILayout.EndHorizontal();
			}
		}
	}

	@:overload override public function OnInspectorGUI()
	{
		var path = AssetDatabase.GetAssetPath(target);
		switch (path.split('.').pop())
		{
			case 'hxml' if (path == 'Assets/build.hxml'):
				if (this.prop == null)
				{
					this.prop = Globals.chain.hxml;
				}
				HxmlOnGUI(this.prop);
				Repaint();

			case 'hx' | 'hxml':
				var last = GUI.enabled;
				GUI.enabled = true;
				scroll = GUILayout.BeginScrollView(scroll, new cs.NativeArray(0));
				GUI.enabled = false;
				GUILayout.Label(sys.io.File.getContent( AssetDatabase.GetAssetPath(target) ), null);
				GUI.enabled = true;
				GUILayout.EndScrollView();
				GUI.enabled = last;

			case _:
				super.OnInspectorGUI();
		}
	}
}
