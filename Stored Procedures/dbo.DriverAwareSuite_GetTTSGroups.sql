SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO




CREATE Procedure [dbo].[DriverAwareSuite_GetTTSGroups]

As

Select 'ALL' as GroupID

Union ALL

Select RTrim(grp_id) as GroupID
From   ttsgroups (NOLOCK)





GO
GRANT EXECUTE ON  [dbo].[DriverAwareSuite_GetTTSGroups] TO [public]
GO
