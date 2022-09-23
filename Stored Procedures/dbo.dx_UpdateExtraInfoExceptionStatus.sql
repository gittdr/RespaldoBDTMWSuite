SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[dx_UpdateExtraInfoExceptionStatus] (
@ord_hdrnumber int
)

AS

	DECLARE @CurrentExtraInfo varchar(30)
	DECLARE @ediexceptionstatus varchar(30)
	DECLARE @ReturnCode int
	
	DECLARE @sqlCommand nvarchar(1000)
	DECLARE @ExtraInfoColumnName varchar(30)
	SELECT @ExtraInfoColumnName = 'ord_extrainfo' + gi_string1 from GeneralInfo where gi_name = 'EDIExtraInfoExceptionStatus'
	If @ExtraInfoColumnName = 'ord_extrainfo'
		Return -1
	
	SET @sqlCommand = 'SELECT @CurrentExtraInf=IsNull(' + @ExtraInfoColumnName + ','''') from orderheader where ord_hdrnumber = @ord_hdrnumber '
	EXECUTE sp_executesql @sqlCommand, N'@ord_hdrnumber int,@CurrentExtraInf nvarchar(30) OUTPUT', @ord_hdrnumber = @ord_hdrnumber, @CurrentExtraInf=@CurrentExtraInfo OUTPUT
	
	
	IF (SELECT COUNT(1) FROM dx_archive
		WHERE dx_orderhdrnumber = @ord_hdrnumber and dx_field001 = '02' 
		and dx_processed = 'WAIT') > 0     
			SET @ediexceptionstatus = '2'
	ELSE
		IF (SELECT COUNT(1) FROM orderheader Left Join edi_orderstate On ord_edistate = esc_code
		WHERE ord_hdrnumber = @ord_hdrnumber and (ord_edistate > 39 or IsNull(edi_orderstate.esc_useractionrequired,'N') = 'Y')) > 0
			SET @ediexceptionstatus = '1'
		ELSE
			SET @ediexceptionstatus = ''

	IF @CurrentExtraInfo <> @ediexceptionstatus 
		BEGIN
			SET @sqlCommand = 'UPDATE orderheader set ' + @ExtraInfoColumnName + ' = @ediexceptionstatus where ord_hdrnumber = @ord_hdrnumber '
			EXECUTE sp_executesql @sqlCommand, N'@ord_hdrnumber int,@ediexceptionstatus nvarchar(30) ', @ord_hdrnumber = @ord_hdrnumber, @ediexceptionstatus=@ediexceptionstatus 
		END
	
	SET @ReturnCode = CONVERT(int,@ediexceptionstatus) 
	
	RETURN @ReturnCode 

GO
GRANT EXECUTE ON  [dbo].[dx_UpdateExtraInfoExceptionStatus] TO [public]
GO
