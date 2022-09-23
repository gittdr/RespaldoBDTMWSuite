SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO





--EXEC  sp_envia_archivo_tif 'TDR5567'
CREATE      ProCEDURE [dbo].[sp_envia_archivo_tif](
@s_referencia char(10)
) AS

Declare  @instruccion char(250)
 

select @instruccion  = 'C:\Program Files\Total PDF Converter\PDFConverter.EXE I:\'+ ltrim(rtrim(@s_referencia)) + 'factura.pdf  G:\indices_pdf\' +ltrim(rtrim(@s_referencia))+ 'factura.tif  -c tif -ps LetterSmall'
exec  master.dbo.XYRunProc @instruccion
---("C:\Program Files\Total PDF Converter\PDFConverter.EXE  I:\"+ @s_referencia + "factura.pdf  G:\indices_pdf\" + @s_referencia + "factura.tif  -c tif -ps LetterSmall")


--C:\Program Files\Total PDF Converter\PDFConverter.EXE  I:\TDR5567factura.pdf  G:\indices_pdf\TDR5567factura.tif  -c tif -ps LetterSmall





GO
