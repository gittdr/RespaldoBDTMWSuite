SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--create Proc SpToTextFile_jr
--AS 
CREATE Proc [dbo].[SpToTextFile_jr] 
AS 
DECLARE @Comando VARCHAR(2048) 
SET @Comando='Exec Master..xp_Cmdshell ''bcp "select NOM_FILE_XML from advanpro_pordusa.dbo.talon_electronica where talon_clave =1" queryout "c:\logs\SQLRocks.txt" -S BSCJDELGAD -T -c''' 
print @comando
EXEC(@Comando)
--DECLARE @Comando VARCHAR(2048) 
----SET @Comando='Exec Master..xp_Cmdshell ''bcp "select NOM_FILE_XML from advanpro_pordusa.dbo.talon_electronica where talon_clave =1" queryout "c:\logs\SQLRocks.txt" -S BSCJDELGAD -T -c''' 
--SET @Comando='Exec Master..xp_Cmdshell ''bcp "select NOM_FILE_XML from tmwsuite.dbo.manpowerprofile where mpp_status ="AVL"" queryout "c:\logs\SQLRocks.txt" -S BSCJDELGAD -T -c''' 

--print @comando
--EXEC(@Comando)



--exec SpToTextFile_jr


GO
