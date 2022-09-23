SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ds_tar_edit_bill_accessorial_d_sp]
( @primary_tar_number      INT
, @acc_trk_tar_number      INT
, @acc_trk_trk_number      INT
) AS

/**
 *
 * NAME:
 * dbo.ds_tar_edit_bill_accessorial_d_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for updating tables tariffaccessorial, tariffkey and tariffheader
 *
 * RETURNS:
 *
 * NONE
 *
 * PARAMETERS:
 * @primary_tar_number      INT
 * @acc_trk_tar_number      INT
 * @acc_trk_trk_number      INT
 *
 *
 * REVISION HISTORY:
 * PTS 62530 SPN Created 06/15/12
 *
 **/

SET NOCOUNT ON

BEGIN

   --Data Validation
   IF @primary_tar_number IS NULL OR @primary_tar_number <= 0
      BEGIN
         RAISERROR('A Primary Tariff# is required',16,1)
         RETURN
      END

   IF NOT EXISTS (SELECT 1
                    FROM tariffheader WITH (NOLOCK)
                   WHERE tar_number = @primary_tar_number
                 )
      BEGIN
         RAISERROR('Primary Tariff# not found',16,1)
         RETURN
      END

   IF @acc_trk_tar_number IS NULL OR @acc_trk_tar_number <= 0
      BEGIN
         RAISERROR('A Secondary Tariff# is required',16,1)
         RETURN
      END

   IF NOT EXISTS (SELECT 1
                    FROM tariffheader WITH (NOLOCK)
                   WHERE tar_number = @acc_trk_tar_number
                 )
      BEGIN
         RAISERROR('Secondary Tariff# not found',16,1)
         RETURN
      END

   IF @acc_trk_trk_number IS NULL OR @acc_trk_trk_number <= 0
      BEGIN
         RAISERROR('A Secondary Tariff Key is required',16,1)
         RETURN
      END

   IF NOT EXISTS (SELECT 1
                    FROM tariffkey WITH (NOLOCK)
                   WHERE trk_number = @acc_trk_trk_number
                 )
      BEGIN
         RAISERROR('Secondary Tariff Key not found',16,1)
         RETURN
      END

   --IF EXISTS (SELECT 1
   --             FROM invoicedetail
   --            WHERE tar_number = @acc_trk_tar_number
   --          )
   --   BEGIN
   --      RAISERROR('Secondary Tariff cannot be deleted because it is already used',16,1)
   --      RETURN
   --   END

   --TariffAccessorial
   DELETE FROM tariffaccessorial
    WHERE tar_number = @primary_tar_number
      AND trk_number = @acc_trk_trk_number

   --Tariffkey for the Accessorial
   DELETE FROM tariffkey
    WHERE tar_number = @acc_trk_tar_number
      AND trk_number = @acc_trk_trk_number

   --Tariffheader for the Accessorial
   IF 0 = (SELECT COUNT(1)
             FROM tariffkey
            WHERE tar_number = @acc_trk_tar_number
          )
      BEGIN
         DELETE FROM tariffratehistory
          WHERE tar_number = @acc_trk_tar_number

         DELETE FROM tariffrate
          WHERE tar_number = @acc_trk_tar_number

         DELETE FROM tariffrowcolumn
          WHERE tar_number = @acc_trk_tar_number

         DELETE FROM tariffheader
          WHERE tar_number = @acc_trk_tar_number
      END

END
GO
GRANT EXECUTE ON  [dbo].[ds_tar_edit_bill_accessorial_d_sp] TO [public]
GO
