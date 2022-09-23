SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE Function [dbo].[fnc_TMWRN_EmailSend] 
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

	DECLARE @Email varchar(500)
	
	SELECT @Email= dbo.fnc_TMWRN_EmailSend2(@ParameterToUseForDynamicEmail, @Company, @Division, @Domicile, @DrvExp, @DrvType1, @DrvType2, @DrvType3, @DrvType4, 
													@Regions, @RevType1, @RevType2, @RevType3, @RevType4, @TeamLeader, @Terminal, @TrcExp, 
													@TrcType1, @TrcType2, @TrcType3, @TrcType4, @TrlExp, @TrlType1, @TrlType2, @TrlType3, @TrlType4, @BookedBy, 'ORIGINALBEHAVIOR')

	RETURN @Email
End

GO
GRANT EXECUTE ON  [dbo].[fnc_TMWRN_EmailSend] TO [public]
GO
