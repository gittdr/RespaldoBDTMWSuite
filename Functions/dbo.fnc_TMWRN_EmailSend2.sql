SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Function [dbo].[fnc_TMWRN_EmailSend2] 
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
	@BookedBy varchar(8)='',
	@Fleet varchar(20)=''
)

Returns varchar(500)

As

Begin	

Declare @Email varchar(255)

Set @Email = ''

IF @Company <> '' and CHARINDEX('Company',@ParameterToUseForDynamicEmail)>0
	SET @Email = 	(	
						SELECT label_ExtraString1 
						FROM labelfile 
						WHERE labeldefinition = 'Company'
							AND @Company = abbr
					)
IF @Division <> '' and CHARINDEX('Division',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email + 	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'Division'
										AND @Division = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email = 	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'Division'
								AND @Division = abbr
						)
	END
IF @Domicile <> '' and CHARINDEX('Domicile',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email +	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'Domicile'
									AND @Domicile = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email = 	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'Domicile'
							AND @Domicile = abbr
						)
	END

IF @DrvExp <> '' and CHARINDEX('DrvExp',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email +	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'DrvExp'
										AND @DrvExp = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email = 	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'DrvExp'
								AND @DrvExp = abbr
						)
	END

IF @DrvType1 <> '' and CHARINDEX('DrvType1',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @EMail + 	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'DrvType1'
										AND @DrvType1 = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email =  	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'DrvType1'
								AND @DrvType1 = abbr
						)
	END
IF @DrvType2 <> '' and CHARINDEX('DrvType2',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email + 	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'DrvType2'
										AND @DrvType2 = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email =  	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'DrvType2'
								AND @DrvType2 = abbr
						)
	END

IF @DrvType3 <> '' and CHARINDEX('DrvType3',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email +	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'DrvType3'
										AND @DrvType3 = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email = 	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'DrvType3'
								AND @DrvType3 = abbr
						)		
	END
IF @DrvType4 <> '' and CHARINDEX('DrvType4',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email +	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'DrvType4'
										AND @DrvType4 = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email = 	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'DrvType4'
								AND @DrvType4 = abbr
						)
	END

IF @Regions <> '' and CHARINDEX('Regions',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email +	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'Regions'
										AND @Regions = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email = 	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'Regions'
								AND @Regions = abbr
						)
	END
IF @RevType1 <> '' and CHARINDEX('RevType1',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''	
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email + 	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'RevType1'
										AND @RevType1 = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email =  	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'RevType1'
								AND @RevType1 = abbr
						)
	END

IF @RevType2 <> '' and CHARINDEX('RevType2',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email +	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'RevType2'
										AND @RevType2 = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email = 	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'RevType2'
								AND @RevType2 = abbr
						)
	END

IF @RevType3 <> '' and CHARINDEX('RevType3',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email +	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'RevType3'
										AND @RevType3 = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email = 	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'RevType3'
								AND @RevType3 = abbr
						)
	END

IF @RevType4 <> '' and CHARINDEX('RevType4',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email + 	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'RevType4'
										AND @RevType4 = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email =  	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'RevType4'
								AND @RevType4 = abbr
						)
	END

IF @TeamLeader <> '' and CHARINDEX('TeamLeader',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email +	(	
									SELECT teamleader_email 
									FROM labelfile 
									WHERE labeldefinition = 'TeamLeader'
										AND @TeamLeader = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email = 	(	
							SELECT teamleader_email 
							FROM labelfile 
							WHERE labeldefinition = 'TeamLeader'
								AND @TeamLeader = abbr
						)
	END

IF @Terminal <> '' and CHARINDEX('Terminal',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email + 	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'Terminal'
										AND @Terminal = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email = 	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'Terminal'
								AND @Terminal = abbr
						)
	END

IF @TrcExp <> '' and CHARINDEX('TrcExp',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email +	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'TrcExp'
										AND @TrcExp = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email = 	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'TrcExp'
								AND @TrcExp = abbr
						)
	END

IF @TrcType1 <> '' and CHARINDEX('TrcType1',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email +	ISNull((	
										SELECT label_ExtraString1 
										FROM labelfile 
										WHERE labeldefinition = 'TrcType1'
											AND @TrcType1 = abbr
									),'')
	END
	ELSE
	BEGIN
		SET @Email = 	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'TrcType1'
								AND @TrcType1 = abbr
						)	
	END

IF @TrcType2 <> '' and CHARINDEX('TrcType2',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email +	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'TrcType2'
										AND @TrcType2 = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email = 	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'TrcType2'
								AND @TrcType2 = abbr
						)
	END


IF @TrcType3 <> '' and CHARINDEX('TrcType3',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email + 	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'TrcType3'
										AND @TrcType3 = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email =  	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'TrcType3'
								AND @TrcType3 = abbr
						)
	END

IF @TrcType4 <> '' and CHARINDEX('TrcType4',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email +	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'TrcType4'
										AND @TrcType4 = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email = 	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'TrcType4'
								AND @TrcType4 = abbr
						)
	END

IF @TrlExp <> '' and CHARINDEX('TrlExp',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email +	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'TrlExp'
										AND @TrlExp = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email = 	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'TrlExp'
								AND @TrlExp = abbr
						)
	END

IF @TrlType1 <> '' and CHARINDEX('TrlType1',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email +	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'TrlType1'
										AND @TrlType1 = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email = 	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'TrlType1'
								AND @TrlType1 = abbr
						)
	END

IF @TrlType2 <> '' and CHARINDEX('TrlType2',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email +	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'TrlType2'
										AND @TrlType2 = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email = 	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'TrlType2'
								AND @TrlType2 = abbr
						)
	END

IF @TrlType3 <> '' and CHARINDEX('TrlType3',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email + 	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'TrlType3'
										AND @TrlType3 = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email =  	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'TrlType3'
								AND @TrlType3 = abbr
						)	
	END

IF @TrlType4 <> '' and CHARINDEX('TrlType4',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email +	(	
									SELECT label_ExtraString1 
									FROM labelfile 
									WHERE labeldefinition = 'TrlType4'
										AND @TrlType4 = abbr
								)
	END
	ELSE
	BEGIN
		SET @Email = 	(	
							SELECT label_ExtraString1 
							FROM labelfile 
							WHERE labeldefinition = 'TrlType4'
								AND @TrlType4 = abbr
						)
	END
	
IF @BookedBy <> '' and CHARINDEX('BookedBy',@ParameterToUseForDynamicEmail)>0
	IF @Email <> ''
	BEGIN
		SET @Email = @Email + ';'
		SET @Email = @Email +	(	
									SELECT usr_mail_address 
									FROM ttsusers 
									WHERE usr_userid = @BookedBy
								)
	END
	ELSE
	BEGIN
		SET @Email = 	(	
							SELECT usr_mail_address 
							FROM ttsusers 
							WHERE usr_userid = @BookedBy
						)
	END

IF @Fleet <> 'ORIGINALBEHAVIOR'
BEGIN
	IF @Fleet <> '' and CHARINDEX('Fleet',@ParameterToUseForDynamicEmail)>0
		IF @Email <> ''
		BEGIN
			SET @Email = @Email + ';'
			SET @Email = @Email +	(	
										SELECT label_ExtraString1 
										FROM labelfile 
										WHERE labeldefinition = 'Fleet'
											AND @Fleet = abbr
									)
		END
		ELSE
		BEGIN
			SET @Email = 	(	
								SELECT label_ExtraString1 
								FROM labelfile 
								WHERE labeldefinition = 'Fleet'
									AND @Fleet = abbr
							)
		END
END
Return @Email
End

GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_EmailSend2] TO [public]
GO
