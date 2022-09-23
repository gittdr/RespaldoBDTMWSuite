SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[sp_generate_expiration]
( @exp_source           VARCHAR(30)
, @asgn_type            VARCHAR(3)
, @asgn_id              VARCHAR(13)
, @exp_code             VARCHAR(6)
, @exp_priority         VARCHAR(6)
, @exp_expirationdate   DATETIME
, @exp_description      VARCHAR(100)
, @Action               CHAR(1)
, @carriercsalogdtl_id  INT
) AS
/**
 *
 * NAME:
 * dbo.sp_generate_expiration
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used for maintaining rows in table expiration
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @exp_source         VARCHAR(30)
 * 002 @asgn_type          VARCHAR(3)
 * 003 @asgn_id            VARCHAR(13)
 * 004 @exp_code           VARCHAR(6)
 * 005 @exp_priority       VARCHAR(6)
 * 006 @exp_expirationdate DATETIME
 * 007 @exp_description    VARCHAR(100)
 * 008 @Action             CHAR(1)
 *
 * REVISION HISTORY:
 * PTS 56555 SPN 10/04/11 - Initial Version Created
 *
 **/

SET NOCOUNT ON

BEGIN
   DECLARE @debug_ind                           CHAR(1)

   DECLARE @msg                  VARCHAR(1000)
   DECLARE @count                INT
   DECLARE @idt_apocalypse       DATETIME
   DECLARE @idt_genesis          DATETIME
   DECLARE @exp_lastdate         DATETIME

   SELECT @debug_ind      = 'N'
   SELECT @idt_genesis    = '2050-01-01 00:00:00'
   SELECT @idt_apocalypse = '2049-12-31 23:59:00'

   IF @exp_source IS NULL
   BEGIN
      SELECT @msg = 'Source cannot be blank.'
      RAISERROR(@msg, 11, 1)
   END

   IF @asgn_type IS NULL
   BEGIN
      SELECT @msg = 'Asset Type cannot be blank.'
      RAISERROR(@msg, 11, 1)
   END

   IF @asgn_type NOT IN ('CAR','DRV','TRC','TRL','TPR')
   BEGIN
      SELECT @msg = 'Asset Type: ' + @asgn_type + ' is not a valid type.'
      RAISERROR(@msg, 11, 1)
   END

   IF @asgn_id IS NULL
   BEGIN
      SELECT @msg = 'Asset ID cannot be blank.'
      RAISERROR(@msg, 11, 1)
   END
   IF @exp_code IS NULL
   BEGIN
      SELECT @msg = @asgn_type + ' ' + @asgn_id + ': Expiration Code cannot be blank.'
      RAISERROR(@msg, 11, 1)
   END
   IF @exp_priority IS NULL
   BEGIN
      SELECT @msg = @asgn_type + ' ' + @asgn_id + ': Expiration Priority cannot be blank.'
      RAISERROR(@msg, 11, 1)
   END

   IF @exp_expirationdate IS NULL
   BEGIN
      SELECT @exp_expirationdate = GetDate()
   END
   SELECT @exp_lastdate = @idt_genesis

   BEGIN
      If @debug_ind = 'Y'
      BEGIN
         Print @exp_source + ' ' + @asgn_type + ' ' + @asgn_id + ' ' + @exp_code
      END

      SELECT @count = COUNT(1)
        FROM expiration
       WHERE IsNull(exp_completed,'N') = 'N'
         AND exp_source = @exp_source
         AND exp_idtype = @asgn_type
         AND exp_id     = @asgn_id
         AND exp_code   = @exp_code

      --Disable Expiration by setting the date to 12/31/2049
      IF @Action = 'D'
      BEGIN
         IF @count > 0
            BEGIN
               SELECT @exp_expirationdate = @idt_apocalypse
               SELECT @exp_lastdate = MAX(exp_expirationdate)
                 FROM expiration
                WHERE IsNull(exp_completed,'N') = 'N'
                  AND exp_source = @exp_source
                  AND exp_idtype = @asgn_type
                  AND exp_id     = @asgn_id
                  AND exp_code   = @exp_code
            END
         ELSE
            BEGIN
               SELECT @msg = @asgn_type + ' ' + @asgn_id + ': No Expiration found to be disabled.'
               IF @debug_ind = 'Y'
               BEGIN
                  Print @msg
               END
            END
      END

      IF @count = 0 AND @Action <> 'D'
         BEGIN
            INSERT INTO expiration
            ( exp_source
            , exp_idtype
            , exp_id
            , exp_code
            , exp_priority
            , exp_description
            , exp_expirationdate
            , exp_lastdate
            , exp_compldate
            , exp_updateby
            , exp_creatdate
            , exp_updateon
            , exp_auto_created
            , exp_completed
            , exp_routeto
            , carriercsalogdtl_id
            )
            VALUES
            ( @exp_source
            , @asgn_type
            , @asgn_id
            , @exp_code
            , @exp_priority
            , @exp_description
            , @exp_expirationdate
            , @exp_lastdate
            , @idt_apocalypse
            , USER
            , GetDate()
            , GetDate()
            , 'Y'
            , 'N'
            , 'UNKNOWN'
            , @carriercsalogdtl_id
            )
         END

      IF @count <> 0
         BEGIN
            If @debug_ind = 'Y'
            BEGIN
               Print 'Updating Expiration ' + Convert(varchar,@exp_expirationdate)
            END
            If @Action <> 'D'
               BEGIN
                  UPDATE expiration
                     SET exp_priority        = @exp_priority
                       , exp_description     = @exp_description
                       , exp_expirationdate  = @exp_expirationdate
                       , exp_lastdate        = @exp_lastdate
                       , exp_updateby        = user
                       , exp_updateon        = GetDate()
                       , exp_auto_created    = 'Y'
                       , carriercsalogdtl_id = @carriercsalogdtl_id
                   WHERE IsNull(exp_completed,'N') = 'N'
                     AND exp_source = @exp_source
                     AND exp_idtype = @asgn_type
                     AND exp_id     = @asgn_id
                     AND exp_code   = @exp_code
               END
            Else
               BEGIN
                  UPDATE expiration
                     SET exp_description     = @exp_description
                       , exp_expirationdate  = @exp_expirationdate
                       , exp_lastdate        = @exp_lastdate
                       , exp_updateby        = user
                       , exp_updateon        = GetDate()
                       , exp_auto_created    = 'Y'
                       , carriercsalogdtl_id = @carriercsalogdtl_id
                   WHERE IsNull(exp_completed,'N') = 'N'
                     AND exp_source = @exp_source
                     AND exp_idtype = @asgn_type
                     AND exp_id     = @asgn_id
                     AND exp_code   = @exp_code
               END

         END

   END

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[sp_generate_expiration] TO [public]
GO
