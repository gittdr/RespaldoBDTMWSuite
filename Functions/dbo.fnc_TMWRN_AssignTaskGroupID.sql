SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE Function [dbo].[fnc_TMWRN_AssignTaskGroupID]
(
	@ParameterToUseForDynamicEmail varchar(255) ='',
	@Company varchar(6)='',
	@Division varchar(6)='',
	@Domicile varchar(6)='',
	@DrvExp varchar(6)='',
	@DrvType1 varchar(6)='',
	@DrvType2 varchar(6)='',
	@DrvType3 varchar(6)='',
	@DrvType4 varchar(6)='',
	@Regions varchar(6)='',
	@RevType1 varchar(6)='',
	@RevType2 varchar(6)='',
	@RevType3 varchar(6)='',
	@RevType4 varchar(6)='',
	@TeamLeader varchar(6)='',
	@Terminal varchar(6)='',
	@TrcExp varchar(6)='',
	@TrcType1 varchar(6)='',
	@TrcType2 varchar(6)='',
	@TrcType3 varchar(6)='',
	@TrcType4 varchar(6)='',
	@TrlExp varchar(6)='',
	@TrlType1 varchar(6)='',
	@TrlType2 varchar(6)='',
	@TrlType3 varchar(6)='',
	@TrlType4 varchar(6)='',
	@BookedBy varchar(8)
)

Returns varchar(500)

As

Begin	

Declare @GroupID varchar(255)

Set @GroupID = ''

IF @Company <> '' and CHARINDEX('Company',@ParameterToUseForDynamicEmail)>0
	SET @GroupID = 	(	
						SELECT label_ExtraString2
						FROM labelfile 
						WHERE labeldefinition = 'Company'
							AND @Company = abbr
					)
IF @Division <> '' and CHARINDEX('Division',@ParameterToUseForDynamicEmail)>0
	
	
		SET @GroupID = 	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'Division'
								AND @Division = abbr
						)
	
IF @Domicile <> '' and CHARINDEX('Domicile',@ParameterToUseForDynamicEmail)>0
	
	
		SET @GroupID = 	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'Domicile'
							AND @Domicile = abbr
						)
	

IF @DrvExp <> '' and CHARINDEX('DrvExp',@ParameterToUseForDynamicEmail)>0
	
	
		SET @GroupID = 	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'DrvExp'
								AND @DrvExp = abbr
						)
	

IF @DrvType1 <> '' and CHARINDEX('DrvType1',@ParameterToUseForDynamicEmail)>0
	
		SET @GroupID =  	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'DrvType1'
								AND @DrvType1 = abbr
						)
	
IF @DrvType2 <> '' and CHARINDEX('DrvType2',@ParameterToUseForDynamicEmail)>0
	
		SET @GroupID =  	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'DrvType2'
								AND @DrvType2 = abbr
						)
	

IF @DrvType3 <> '' and CHARINDEX('DrvType3',@ParameterToUseForDynamicEmail)>0
	
		SET @GroupID = 	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'DrvType3'
								AND @DrvType3 = abbr
						)		
	
IF @DrvType4 <> '' and CHARINDEX('DrvType4',@ParameterToUseForDynamicEmail)>0
	
		SET @GroupID = 	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'DrvType4'
								AND @DrvType4 = abbr
						)
	

IF @Regions <> '' and CHARINDEX('Regions',@ParameterToUseForDynamicEmail)>0
	
		SET @GroupID = 	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'Regions'
								AND @Regions = abbr
						)
	
IF @RevType1 <> '' and CHARINDEX('RevType1',@ParameterToUseForDynamicEmail)>0
	
		SET @GroupID =  	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'RevType1'
								AND @RevType1 = abbr
						)
	

IF @RevType2 <> '' and CHARINDEX('RevType2',@ParameterToUseForDynamicEmail)>0
	
		SET @GroupID = 	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'RevType2'
								AND @RevType2 = abbr
						)
	

IF @RevType3 <> '' and CHARINDEX('RevType3',@ParameterToUseForDynamicEmail)>0
	
		SET @GroupID = 	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'RevType3'
								AND @RevType3 = abbr
						)
	

IF @RevType4 <> '' and CHARINDEX('RevType4',@ParameterToUseForDynamicEmail)>0

		SET @GroupID =  	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'RevType4'
								AND @RevType4 = abbr
						)
	
IF @TeamLeader <> '' and CHARINDEX('TeamLeader',@ParameterToUseForDynamicEmail)>0
	
		SET @GroupID = 	(	
							SELECT label_extrastring2
							FROM labelfile 
							WHERE labeldefinition = 'TeamLeader'
								AND @TeamLeader = abbr
						)
	
IF @Terminal <> '' and CHARINDEX('Terminal',@ParameterToUseForDynamicEmail)>0
	
		SET @GroupID = 	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'Terminal'
								AND @Terminal = abbr
						)
	

IF @TrcExp <> '' and CHARINDEX('TrcExp',@ParameterToUseForDynamicEmail)>0
	
		SET @GroupID = 	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'TrcExp'
								AND @TrcExp = abbr
						)
	

IF @TrcType1 <> '' and CHARINDEX('TrcType1',@ParameterToUseForDynamicEmail)>0
	
		SET @GroupID = 	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'TrcType1'
								AND @TrcType1 = abbr
						)	
	

IF @TrcType2 <> '' and CHARINDEX('TrcType2',@ParameterToUseForDynamicEmail)>0
	
		SET @GroupID = 	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'TrcType2'
								AND @TrcType2 = abbr
						)
	

IF @TrcType3 <> '' and CHARINDEX('TrcType3',@ParameterToUseForDynamicEmail)>0
	
		SET @GroupID =  	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'TrcType3'
								AND @TrcType3 = abbr
						)
	

IF @TrcType4 <> '' and CHARINDEX('TrcType4',@ParameterToUseForDynamicEmail)>0
	
		SET @GroupID = 	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'TrcType4'
								AND @TrcType4 = abbr
						)
	

IF @TrlExp <> '' and CHARINDEX('TrlExp',@ParameterToUseForDynamicEmail)>0
	
		SET @GroupID = 	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'TrlExp'
								AND @TrlExp = abbr
						)
	

IF @TrlType1 <> '' and CHARINDEX('TrlType1',@ParameterToUseForDynamicEmail)>0
	
	
		SET @GroupID = 	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'TrlType1'
								AND @TrlType1 = abbr
						)
	

IF @TrlType2 <> '' and CHARINDEX('TrlType2',@ParameterToUseForDynamicEmail)>0
	
		SET @GroupID = 	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'TrlType2'
								AND @TrlType2 = abbr
						)
	

IF @TrlType3 <> '' and CHARINDEX('TrlType3',@ParameterToUseForDynamicEmail)>0
	
		SET @GroupID =  	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'TrlType3'
								AND @TrlType3 = abbr
						)	
	
IF @TrlType4 <> '' and CHARINDEX('TrlType4',@ParameterToUseForDynamicEmail)>0
	
		SET @GroupID = 	(	
							SELECT label_ExtraString2
							FROM labelfile 
							WHERE labeldefinition = 'TrlType4'
								AND @TrlType4 = abbr
						)
	

Return @GroupID
End

GO
