SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create FUNCTION [dbo].[fnc_BranchHierarchyForRN]() 
RETURNS @t TABLE 
	( 
		RowId int IDENTITY
		,brn_parent_1 varchar(12)
		,brn_id_1 varchar(12)
		,brn_name_1 varchar(40)
		,brn_parent_2 varchar(12)
		,brn_id_2 varchar(12)
		,brn_name_2 varchar(40)
		,brn_parent_3 varchar(12)
		,brn_id_3 varchar(12)
		,brn_name_3 varchar(40)
		,brn_parent_4 varchar(12)
		,brn_id_4 varchar(12)
		,brn_name_4 varchar(40)
		,brn_parent_5 varchar(12)
		,brn_id_5 varchar(12)
		,brn_name_5 varchar(40)
	) 
AS 
BEGIN 

        INSERT INTO @t 		(brn_parent_1 ,brn_id_1 ,brn_name_1 ,brn_parent_2 ,brn_id_2 ,brn_name_2 ,brn_parent_3 ,brn_id_3 ,brn_name_3 ,brn_parent_4 
		,brn_id_4 ,brn_name_4 ,brn_parent_5 ,brn_id_5 ,brn_name_5 )
        SELECT 	brn_parent_1 ,brn_id_1 ,brn_name_1 ,brn_parent_2 ,brn_id_2 ,brn_name_2 ,brn_parent_3 ,brn_id_3 ,brn_name_3 ,brn_parent_4 
				,brn_id_4 ,brn_name_4 ,brn_parent_5 ,brn_id_5 ,brn_name_5 
		FROM BranchHierarchyForRN 
		order by brn_id_1,brn_id_2,brn_id_3,brn_id_4
        RETURN 
END 
GO
GRANT SELECT ON  [dbo].[fnc_BranchHierarchyForRN] TO [public]
GO
