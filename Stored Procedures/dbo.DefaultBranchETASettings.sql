SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[DefaultBranchETASettings] (@brn_id as varchar(12))
AS

/*    WARNING THIS WILL CLEAR ALL VALUES FOR A GIVEN BRANCH AND CREATE DEFAULT ENTRIES FOR A BRANCH */
delete from ETABranchSettingValues where ebsv_branch = @brn_id

insert into ETABranchSettingValues(ebsv_branch, esbs_name, ebsv_value)
select @brn_id, esbs_name, esbs_defaultvalue
  from ETASupportedBranchSettings

GO
GRANT EXECUTE ON  [dbo].[DefaultBranchETASettings] TO [public]
GO
