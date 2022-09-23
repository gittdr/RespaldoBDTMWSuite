SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[addlabelfileforstlmnt_sp] (@p_format varchar(60),@p_abbr varchar(6), @p_thirdparty varchar(6))
AS


/*
 * NAME:
 * dbo.addlabelfileforstlmnt_sp
 *
 * TYPE:
 * storedprocedure
 *
 * DESCRIPTION:
 * Given the labelfile name and abbr perform the dsb mod for labelfile work for a new Settlement sheet format

 * RETURNS:
 *
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - @p_format varchar(20) name if the invoice or mb format (EG d_inv_format134)
 * 002 - @p_abbr varchar(6) labelfile abbr value for the new format
 * 003 - @p_thirdparty varchar(6) TPY if third party format, blank otherwise
 *
 * REFERENCES:
 * 
 * REVISION HISTORY:
 * 2009.08.26.01 vjh PTS48481 create proc (stealing largely from addlabelfileforinvormb_sp)
 **/ 

IF NOT EXISTS (SELECT 1 FROM labelfile
   		       WHERE name = @p_abbr AND labeldefinition = 'StlmntSelection')
BEGIN
	DECLARE @v_code int
	--Get max labelfile code.
	SELECT @v_code = Max(ISNULL(code, 0))+1 FROM labelfile where labeldefinition = 'StlmntSelection'
	if @v_code is null  select @v_code = 1

	INSERT INTO labelfile(labeldefinition,name,abbr,code,locked,userlabelname,systemcode,retired,inventory_item, label_extrastring1, label_extrastring2) 
	VALUES('StlmntSelection',@p_abbr ,@p_abbr,@v_code,'Y',@p_abbr,'Y','N','N',@p_format,@p_thirdparty)
END
ELSE
BEGIN
   Update labelfile
   SET label_extrastring1 = @p_format
   WHERE labeldefinition = 'StlmntSelection' AND abbr = @p_abbr
END

GO
GRANT EXECUTE ON  [dbo].[addlabelfileforstlmnt_sp] TO [public]
GO
