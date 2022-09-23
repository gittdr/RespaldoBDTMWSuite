SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO







CREATE       PROCEDURE [dbo].[sp_md5] (@cadena text, @pstrout char(32) output )  AS
begin 

	select @pstrout = tdr.dbo.fn_md5(@cadena)
	print @pstrout 

end




GO
