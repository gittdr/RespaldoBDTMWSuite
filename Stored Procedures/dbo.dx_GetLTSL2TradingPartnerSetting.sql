SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[dx_GetLTSL2TradingPartnerSetting] (
@settingName varchar(255), @trp_id varchar(255))

AS
	DECLARE @ReturnValue int 

	IF (select Count(*) from dx_xref where dx_trpid = @trp_id and dx_entityname = @settingName and dx_xrefkey = '1') = 1     
		SET @ReturnValue = 1
	ELSE
		SET @ReturnValue = 0
					   
	RETURN @ReturnValue

GO
GRANT EXECUTE ON  [dbo].[dx_GetLTSL2TradingPartnerSetting] TO [public]
GO
