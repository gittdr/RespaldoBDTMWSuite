SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:      ALG
-- Create date: 11 JULIO 2009
-- Description: GENERA UN ID PARA LA TABLA IDENT_CKCNUM UTILIZANDO EL SP DE TMW
-- =============================================
CREATE PROCEDURE [dbo].[savl_generaid](@tabla int)
AS
DECLARE   @id  int
BEGIN
    -- 1 : tabla de posiciones CheckCall
    -- 2 : tabla de mensajes ?
     IF @tabla = 1 BEGIN
      EXEC @id = dbo.getsystemnumber N'CKCNUM', NULL
    END

    -- Insert statements for procedure here
    DELETE FROM SAVL_ID
     INSERT INTO SAVL_ID (ID) VALUES (@id);
END

GO
