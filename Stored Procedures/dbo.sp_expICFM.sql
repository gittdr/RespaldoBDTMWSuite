SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Emilio Olvera
-- Create date: 14/03/2013
-- Description:	 Inserta expiraciones de acuerdo a las condiciones de numero de placa para inspecciones fisico mecanicas
-- =============================================


---exec sp_ExpICFM

CREATE PROCEDURE  [dbo].[sp_expICFM]  AS

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;



--Declaramos la variable que almacenara el remolque y el tractor que pasara al sp que inserta las expiraciones de acuerdo a su ICFM
DECLARE @remolque varchar(10)
DECLARE @tractor varchar(10)

--------------------------------------------Declaramos el cursor para el caso de los remolques----------------------------------------------------------------
DECLARE Cursor_expICFMTRL  CURSOR
 FOR select trl_number  from trailerprofile where trl_company = 'TDR' and trl_retiredate > getdate()
 OPEN Cursor_expICFMTRL
 

--Agregamos el valor del remolque a la variable con la cual se ejecutara el sp ICFMTRL
 fetch next from Cursor_expICFMTRL
 into @remolque
 while @@fetch_Status = 0

 BEGIN

   exec sp_insertaexpICFMTRL  @remolque

   	 --avanzamos el cursor
	 fetch next from Cursor_expICFMTRL
	 into @remolque

 END

	 --cerramos y dealocamos el cursor
	 close Cursor_expICFMTRL
	 deallocate Cursor_expICFMTRL

--------------------------------------------Declaramos el cursor para el caso de los tractores---------------------------------------------------------------

DECLARE Cursor_expICFMTRC  CURSOR
 FOR select trc_number  from tractorprofile where trc_retiredate > getdate()
 OPEN Cursor_expICFMTRC
 

--Agregamos el valor del remolque a la variable con la cual se ejecutara el sp ICFMTRL
 fetch next from Cursor_expICFMTRC
 into @tractor
 while @@fetch_Status = 0

 BEGIN

   exec sp_insertaexpICFMTRC  @tractor
   
   	 --avanzamos el cursor
	 fetch next from Cursor_expICFMTRC
	 into @tractor

 END


	 --cerramos y dealocamos el cursor
	 close Cursor_expICFMTRC
	 deallocate Cursor_expICFMTRC


--------------------------------------------------------------------------------------------------------------------------------------------------------
END
GO
