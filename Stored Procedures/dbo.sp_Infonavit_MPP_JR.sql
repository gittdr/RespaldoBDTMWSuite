SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--  exec sp_Infonavit_MPP_JR

CREATE PROCEDURE [dbo].[sp_Infonavit_MPP_JR]
AS

DECLARE	
@V_mpp_id varchar(8), 
@V_mpp_misc1  varchar(15), 
@V_mpp_misc4   varchar(15), 
@V_mpp_otherid   varchar(8), 
@V_mpp_lastfirst   varchar(50), 
@V_mpp_status  varchar(8), 
@V_mpp_createdate  datetime,
@V_mpp_terminationdt datetime,
@V_standing integer

--	TT_mpp_id,TT_mpp_misc1, TT_mpp_misc3, TT_mpp_otherid,TT_mpp_lastfirst, TT_mpp_status, TT_mpp_createdate 
DECLARE @TT_Driver TABLE(
TT_mpp_id  varchar(8) not null, 
TT_mpp_misc1  varchar(20), 
TT_mpp_misc4  varchar(20), 
TT_mpp_otherid  varchar(8), 
TT_mpp_lastfirst  varchar(60), 
TT_mpp_status varchar(8), 
TT_mpp_createdate datetime,
TT_mpp_terminationdt datetime,
TT_standing integer)

SET NOCOUNT ON


BEGIN --1 Principal


-- Llena la tabla temporal de ordenes de sears.
INSERT Into @TT_Driver(TT_mpp_id,TT_mpp_misc1, TT_mpp_misc4, TT_mpp_otherid,TT_mpp_lastfirst, TT_mpp_status, TT_mpp_createdate,TT_mpp_terminationdt, TT_standing)
		SELECT        mpp_id, mpp_misc1, mpp_misc4, mpp_otherid, mpp_lastfirst, mpp_status, mpp_createdate,mpp_terminationdt,0 FROM dbo.manpowerprofile WHERE (mpp_createdate BETWEEN '2017-01-01' AND '2017-12-31')
		ORDER BY mpp_createdate

-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @TT_Driver )
	BEGIN --3 Si hay movimientos de posiciones
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE drivers_Cursor CURSOR FOR 
		SELECT TT_mpp_id
		FROM @TT_Driver 
	
		OPEN drivers_Cursor 
		FETCH NEXT FROM drivers_Cursor INTO @V_mpp_id

		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor Unidades_Cursor --3
				
			

			select @V_standing = count(*) from standingdeduction where sdm_itemcode = 'INFONA' AND asgn_id = @V_mpp_id


			Update @TT_Driver Set 
				TT_standing	= @V_standing
		 Where TT_mpp_id	= @V_mpp_id
			

		FETCH NEXT FROM drivers_Cursor INTO @V_mpp_id

	END --3 curso de los movimientos 
	CLOSE drivers_Cursor 
	DEALLOCATE drivers_Cursor 
END -- 2 si hay movimientos del RC

 select * from @TT_Driver

END --1 Principal
GO
