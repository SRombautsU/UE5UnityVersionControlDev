// Copyright Epic Games, Inc. All Rights Reserved.

using UnrealBuildTool;
using System.Collections.Generic;

public class UE5UnityVCSDevEditorTarget : TargetRules
{
	public UE5UnityVCSDevEditorTarget( TargetInfo Target) : base(Target)
	{
		Type = TargetType.Editor;
		DefaultBuildSettings = BuildSettingsVersion.V2;
		ExtraModuleNames.AddRange( new string[] { "UE5UnityVCSDev" } );
		
		// Uncomment to rebuild the whole project without Unity Build, compiling each cpp source file individually, in order to test Includ Whay You Use (IWYU) policy
		// WARNING: don't uncomment on UnrealEngine Source Build, else you will trigger a full new Engine build (but easy to revert, will just relink 1200 lib/dll)
		bUseUnityBuild = false;
	}
}
