SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_MaterialPeligroso] (@segmento varchar(100))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	select com.cmd_code, com.cmd_name,com.cmd_hazardous, com.cmd_class, com.cmd_haz_class,com.cmd_haz_subclass,  cat.cat_peligroso
	from commodity as com, cat_mercancia_sat_jr as cat where 
	com.cmd_code = cat.cat_cmd_code and
	com.cmd_code in (
	select cmd_code from freightdetail where stp_number in (select stp_number from stops where lgh_number = @segmento))
	and cat.cat_peligroso = '0,1' and cmd_hazardous = 0 and cmd_class = 'UNKNOWN'
	order by 7 desc
END
GO
