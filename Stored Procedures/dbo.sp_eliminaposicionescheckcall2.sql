SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--exec sp_eliminaposicionescheckcall2
create procedure [dbo].[sp_eliminaposicionescheckcall2]
AS


DECLARE @i_Minmsgs            	integer,
	@i_Maxmsgs            	integer,
	@msg_error	 	varchar(30)

/* Obtiene el minimo de la tabla de checkcall  */

select @i_Minmsgs = Min(ckc_number) from checkcall;

select @i_Maxmsgs = @i_Minmsgs + 40

-- Elimina las posiciones menores al valor @i_Maxmsgs

DELETE checkcall WHERE  ckc_number < @i_Maxmsgs

/*verifica si hubo algun error*/
 IF @@error <> 0 
    BEGIN
      SELECT @msg_error = 'Problemas al borrar las posiciones'
    END
GO
