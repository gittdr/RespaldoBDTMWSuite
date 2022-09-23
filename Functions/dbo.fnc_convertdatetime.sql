SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Emilio Olvera
-- Create date:  Lun 27 Feb 2017
-- Description:	regresa fecha en formato corto en texto
--
-- Setencia de ejemplo:

-- select dbo.fnc_convertdatetime (getdate())
-- =============================================
CREATE FUNCTION [dbo].[fnc_convertdatetime] (@Fecha datetime)

RETURNS varchar(40)
AS
BEGIN

declare @FechaTxt varchar(40)
declare @DiaSem varchar(3)
declare @FechaHora Varchar(30)


SELECT @DiaSem = CASE DATEPART(WEEKDAY,@Fecha)  
    WHEN 1 THEN 'dom' 
    WHEN 2 THEN 'lun' 
    WHEN 3 THEN 'mar' 
    WHEN 4 THEN 'mie' 
    WHEN 5 THEN 'jue' 
    WHEN 6 THEN 'vie' 
    WHEN 7 THEN 'sab' 
END

select @FechaHora =  cast(month(@Fecha)  as varchar(2))+'/' + ( select datename(day,@Fecha)  + ' ' +
	 datename(hour,@Fecha)+':'+ case when len(datename(minute,@Fecha)) = 1 then '0'+ (datename(minute,@Fecha))  else (datename(minute,@Fecha)) end )


select @FechaTxt =  @DiaSem + '. ' + @FechaHora

RETURN @FechaTxt

END
GO
