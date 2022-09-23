SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


Create procedure [dbo].[d_grid_config_sp] (@user_id varchar(20),@is_configuration char(1))
As  
  
CREATE TABLE #objectresult(
	uo_ID int NULL, 
	uo_object varchar(50) NULL, 
	uo_object_description varchar(50) NULL,
	otc_control varchar(50) NULL, 
	otc_control_description varchar(50) NULL, 
	uo_user_id varchar(20) NULL, 
	uo_description varchar(50) NULL, 
	DefaultIndicator tinyint NULL,
	Configuration char(1) -- PTS 52005 SGB 05/21/2010
)

CREATE TABLE #objecttocontrol  (
	object varchar(50),
	control varchar(50),
	control_description varchar(50)
)

INSERT INTO #objecttocontrol
VALUES ('D_TRIPFOLDER_FREIGHT', 'DW_DETAIL1', 'Trip Sheet 1 (Upper)')

INSERT INTO #objecttocontrol
VALUES ('D_TRIPFOLDER_FREIGHT', 'DW_DETAIL2', 'Trip Sheet 2 (Lower)')

INSERT INTO #objecttocontrol
VALUES ('D_TRIPFOLDER_STOPEVENT', 'DW_DETAIL1', 'Trip Sheet 1 (Upper)')

INSERT INTO #objecttocontrol
VALUES ('D_TRIPFOLDER_STOPEVENT', 'DW_DETAIL2', 'Trip Sheet 2 (Lower)')

/*
--BEGIN PTS 52005 SGB 05/21/2010
INSERT INTO #objectresult
SELECT uo.id, uo.object, uo.object, isnull(otc.control,uo.object) , control_description, uo.user_id, uo.description, 0 as DefaultIndicator
FROM userobject uo 
		LEFT OUTER JOIN #objecttocontrol otc on uo.object = otc.object
		LEFT OUTER JOIN ttsusers tu on tu.usr_userid = @user_id
WHERE 	(uo.dwsyntax like '%processing=1%') 
		AND (	uo.user_id = @user_id 
				or uo.user_id = tu.usr_type1 
				
				or exists	(	SELECT * 
								FROM ttsusers tuinner 
								WHERE	tuinner.usr_userid = @user_id 
										AND tuinner.usr_sysadmin = 'Y'
										AND (isnull(uo.usr_type1, '') = '' or uo.usr_type1 = tu.usr_type1)
							)
				
				
				or exists	(	SELECT * 
								FROM ttsusers tuinner 
								WHERE	tuinner.usr_userid = @user_id 
										AND tuinner.usr_supervisor = 'Y' 
										and tuinner.usr_type1 = tu.usr_type1 
										and (ISNULL(uo.usr_type1, tu.usr_type1) = tu.usr_type1)
							)
				
			)


INSERT INTO #objectresult
SELECT DISTINCT 0, uo.object, uo.object, isnull(otc.control,uo.object), control_description, '', 'FACTORY DEFAULT', 1 as DefaultIndicator
FROM	userobject uo 
		LEFT OUTER JOIN #objecttocontrol otc on uo.object = otc.object
		LEFT OUTER JOIN ttsusers tu on tu.usr_userid = @user_id
WHERE	(uo.dwsyntax like '%processing=1%') 
		AND (	uo.user_id = @user_id 
				or uo.user_id = tu.usr_type1 
				or exists	(	SELECT * 
								FROM ttsusers tuinner 
								WHERE	tuinner.usr_userid = @user_id 
										AND tuinner.usr_sysadmin = 'Y'
										AND (isnull(uo.usr_type1, '') = '' or uo.usr_type1 = tu.usr_type1)
							)

				or exists	(	SELECT * 
								FROM ttsusers tuinner 
								WHERE	tuinner.usr_userid = @user_id 
										AND tuinner.usr_supervisor = 'Y' 
										and tuinner.usr_type1 = tu.usr_type1 
										and (ISNULL(uo.usr_type1, tu.usr_type1) = tu.usr_type1)
							)
		)
	*/	
	
	INSERT INTO #objectresult
SELECT uo.id, uo.object, uo.object, isnull(otc.control,uo.object) , control_description, uo.user_id, uo.description, 0 as DefaultIndicator,
CASE 
		WHEN uo.dwsyntax  like '%processing=1%' THEN 'Y'
		ELSE	'N'
	END	
FROM userobject uo 
		LEFT OUTER JOIN #objecttocontrol otc on uo.object = otc.object
		LEFT OUTER JOIN ttsusers tu on tu.usr_userid = @user_id
WHERE 	(	uo.user_id = @user_id 
				or uo.user_id = tu.usr_type1 
				
				or exists	(	SELECT * 
								FROM ttsusers tuinner 
								WHERE	tuinner.usr_userid = @user_id 
										AND tuinner.usr_sysadmin = 'Y'
										AND (isnull(uo.usr_type1, '') = '' or uo.usr_type1 = tu.usr_type1)
							)
				
				
				or exists	(	SELECT * 
								FROM ttsusers tuinner 
								WHERE	tuinner.usr_userid = @user_id 
										AND tuinner.usr_supervisor = 'Y' 
										and tuinner.usr_type1 = tu.usr_type1 
										and (ISNULL(uo.usr_type1, tu.usr_type1) = tu.usr_type1)
							)
				
			)


INSERT INTO #objectresult
SELECT DISTINCT 0, uo.object, uo.object, isnull(otc.control,uo.object), control_description, '', 'FACTORY DEFAULT', 1 as DefaultIndicator,
CASE 
		WHEN uo.dwsyntax  like '%processing=1%' THEN 'Y'
		ELSE	'N'
	END	
FROM	userobject uo 
		LEFT OUTER JOIN #objecttocontrol otc on uo.object = otc.object
		LEFT OUTER JOIN ttsusers tu on tu.usr_userid = @user_id
WHERE	(	uo.user_id = @user_id 
				or uo.user_id = tu.usr_type1 
				or exists	(	SELECT * 
								FROM ttsusers tuinner 
								WHERE	tuinner.usr_userid = @user_id 
										AND tuinner.usr_sysadmin = 'Y'
										AND (isnull(uo.usr_type1, '') = '' or uo.usr_type1 = tu.usr_type1)
							)

				or exists	(	SELECT * 
								FROM ttsusers tuinner 
								WHERE	tuinner.usr_userid = @user_id 
										AND tuinner.usr_supervisor = 'Y' 
										and tuinner.usr_type1 = tu.usr_type1 
										and (ISNULL(uo.usr_type1, tu.usr_type1) = tu.usr_type1)
							)
		)
	-- END PTS 52005 SGB 05/21/2010	

--Final return

SELECT	uo_ID, 
		uo_object, 
		uo_object_description,
		otc_control,
		otc_control_description,
		uo_user_id,
		uo_description,
		DefaultIndicator
FROM #objectresult
Where Configuration = isnull(@is_configuration,'Y') --PTS 52005 SGB 05/21/2010
ORDER BY uo_object, otc_control, DefaultIndicator desc, uo_description

DROP TABLE #objectresult
DROP TABLE #objecttocontrol
   
  
GO
GRANT EXECUTE ON  [dbo].[d_grid_config_sp] TO [public]
GO
