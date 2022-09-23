CREATE TABLE [dbo].[commodity_linkto]
(
[cmd_linkto_id] [int] NOT NULL IDENTITY(1, 1),
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[heirarchy_specificity] [int] NULL,
[last_updateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itut_commodity_linkto]
ON [dbo].[commodity_linkto]
FOR INSERT,UPDATE
AS  
  
/**
 * 
 * NAME:
 * dbo.itut_commodity_linkto
 *
 * TYPE:
 * Trigger
 *
 * DESCRIPTION:
 * This trigger updates userid, last update date and heirarchy_specificity
 *
 * RETURNS:
 * None
 *
 * RESULT SETS: 
 * NONE.
 *
 * PARAMETERS:
 * NONE
 *
 * REFERENCES: 

 * 
 * REVISION HISTORY:
 * 05/18/2011 PTS56318 SPN - Initial Version
 **/
DECLARE @tmwuser                 VARCHAR(255)
DECLARE @cmd_linkto_id           INT
DECLARE @billto                  VARCHAR(8)
DECLARE @revtype1                VARCHAR(6)
DECLARE @revtype2                VARCHAR(6)
DECLARE @revtype3                VARCHAR(6)
DECLARE @revtype4                VARCHAR(6)
DECLARE @heirarchy_specificity   INT
DECLARE @last_updateby           VARCHAR(255)
DECLARE @last_updatedate         DATETIME

BEGIN
   DECLARE myCUR CURSOR FOR
   SELECT cmd_linkto_id
        , billto
        , revtype1
        , revtype2
        , revtype3
        , revtype4
        , heirarchy_specificity
        , last_updateby
        , last_updatedate
     FROM inserted

   EXEC gettmwuser @tmwuser OUTPUT

   OPEN myCUR
   WHILE 1 = 1
   BEGIN
      FETCH NEXT
       FROM myCUR
       INTO @cmd_linkto_id
          , @billto
          , @revtype1
          , @revtype2
          , @revtype3
          , @revtype4
          , @heirarchy_specificity
          , @last_updateby
          , @last_updatedate
      IF @@FETCH_STATUS <> 0
         BREAK

      SELECT @last_updateby = @tmwuser

      SELECT @last_updatedate = GETDATE()

      BEGIN
         SELECT @heirarchy_specificity = 10
         IF @billto IS NOT NULL AND @billto <> '' AND @billto <> 'UNKNOWN'
            SELECT @heirarchy_specificity = @heirarchy_specificity - 5

         IF @revtype1 IS NOT NULL AND @revtype1 <> '' AND @revtype1 <> 'UNK'
            SELECT @heirarchy_specificity = @heirarchy_specificity - 1

         IF @revtype2 IS NOT NULL AND @revtype2 <> '' AND @revtype2 <> 'UNK'
            SELECT @heirarchy_specificity = @heirarchy_specificity - 1

         IF @revtype3 IS NOT NULL AND @revtype3 <> '' AND @revtype3 <> 'UNK'
            SELECT @heirarchy_specificity = @heirarchy_specificity - 1

         IF @revtype4 IS NOT NULL AND @revtype4 <> '' AND @revtype4 <> 'UNK'
            SELECT @heirarchy_specificity = @heirarchy_specificity - 1
      END

      UPDATE commodity_linkto
         SET last_updateby          = @last_updateby
           , last_updatedate        = @last_updatedate
           , heirarchy_specificity  = @heirarchy_specificity
       WHERE cmd_linkto_id = @cmd_linkto_id
   END
   CLOSE myCUR
   DEALLOCATE myCUR
END
RETURN
GO
ALTER TABLE [dbo].[commodity_linkto] ADD CONSTRAINT [pk_cmd_linkto_id] PRIMARY KEY CLUSTERED ([cmd_linkto_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[commodity_linkto] TO [public]
GO
GRANT INSERT ON  [dbo].[commodity_linkto] TO [public]
GO
GRANT REFERENCES ON  [dbo].[commodity_linkto] TO [public]
GO
GRANT SELECT ON  [dbo].[commodity_linkto] TO [public]
GO
GRANT UPDATE ON  [dbo].[commodity_linkto] TO [public]
GO
