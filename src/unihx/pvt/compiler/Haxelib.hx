package unihx.pvt.compiler;
import sys.FileSystem.*;

using StringTools;

@:allow(unihx.pvt.compiler) class Haxelib
{
	var libPath:Null<String>;
	var compiler:HaxeCompiler;

	public function new(comp)
	{
		this.compiler = comp;
	}

	dynamic public function warn(str:String)
	{
		haxe.Log.trace(str,null);
	}

	public function runOrWarn(args:Array<String>)
	{
		var ret = run(args);
		if (ret.exit != 0)
			warn('Haxelib operation failed while running $args:\n${ret.out + '\n' + ret.err}');
		return ret.exit == 0;
	}

	function setLibPath(path)
	{
		this.libPath = path;
		if (path != null && !exists(path))
		{
			createDirectory(path);
		}
		Sys.putEnv('HAXELIB_PATH',path);
	}

	public function list():Array<{ lib:String, ver:String }>
	{
		var ret = run(['list']);
		if (ret.exit == 0)
		{
			var regex = ~/\[([^\]]+)\]/;
			return ret.out.trim().split('\n').map(function(v:String) {
				var s = v.split(':');
				var lib = s.shift().trim(),
				    vers = s.join(':');
				var ver = regex.match(vers) ? regex.matched(1) : vers;
				return { lib: lib, ver:ver };
			});
		}

		warn('Haxelib operation failed:\n${ret.out +'\n' + ret.err}');
		return [];
	}

	public function install(libname:String):Bool
	{
		var ret = run(['install',libname]);
		if (ret.exit != 0)
		{
			warn('install failed:\n${ret.out +'\n' + ret.err}');
			return false;
		}
		return true;
	}

	public function remove(libname:String)
	{
		var ret = run(['remove',libname]);
		if (ret.exit != 0)
		{
			warn('remove failed:\n${ret.out + '\n' + ret.err}');
			return false;
		}
		return true;
	}

	private function getPath()
	{
		var compilerPath = compiler.compilerPath,
		    proc = 'haxelib';
		if (compilerPath != null)
		{
			if (Sys.systemName() == "Windows")
			{
				proc = '$compilerPath/haxelib.exe';
				if (!exists(proc))
					proc = '$compilerPath/haxelib.bat';
			} else {
				proc = '$compilerPath/haxelib';
			}
			if (!exists(proc))
			{
				proc = 'haxelib';
			}
		}
		return proc;
	}

	public function run(args:Array<String>):{ exit:Int, out:String, err:String }
	{
		var proc = getPath();
		var lastPath = compiler.setPath().lastPath;
		var ret = Utils.runProcess(proc,args);
		if (lastPath != null)
			Sys.putEnv('PATH',lastPath);

		return ret;
	}
}
