CREATE TABLE [dbo].[communicator_handle]
(
[communicator_handle_id] [int] NOT NULL IDENTITY(1, 1),
[modulename] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[userid] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[objectname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[handle] [int] NOT NULL,
[handle_prior01] [int] NULL,
[handle_prior02] [int] NULL,
[last_updateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itut_communicator_handle]
ON [dbo].[communicator_handle]
FOR INSERT,UPDATE
AS  
  
/**
 * 
 * NAME:
 * dbo.itut_communicator_handle
 *
 * TYPE:
 * Trigger
 *
 * DESCRIPTION:
 * This trigger updates userid, last update date and handle_prior01, handle_prior02
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
 * 06/07/2011 PTS56472 SPN - Initial Version
 **/
DECLARE @tmwuser                 VARCHAR(255)
DECLARE @communicator_handle_id  INT
DECLARE @new_handle              INT
DECLARE @old_handle              INT
DECLARE @old_handle_prior01      INT
DECLARE @old_handle_prior02      INT
DECLARE @last_updateby           VARCHAR(255)
DECLARE @last_updatedate         DATETIME

BEGIN
   DECLARE myCUR CURSOR FOR
   SELECT communicator_handle_id AS communicator_handle_id
        , IsNull(handle,0)       AS handle
        , (SELECT deleted.handle         FROM deleted WHERE deleted.communicator_handle_id = inserted.communicator_handle_id) AS old_handle
        , (SELECT deleted.handle_prior01 FROM deleted WHERE deleted.communicator_handle_id = inserted.communicator_handle_id) AS old_handle_prior01
        , (SELECT deleted.handle_prior02 FROM deleted WHERE deleted.communicator_handle_id = inserted.communicator_handle_id) AS old_handle_prior02
     FROM inserted
   
   EXEC gettmwuser @tmwuser OUTPUT

   OPEN myCUR
   WHILE 1 = 1
   BEGIN
      FETCH NEXT
       FROM myCUR
       INTO @communicator_handle_id
          , @new_handle
          , @old_handle
          , @old_handle_prior01
          , @old_handle_prior02
      IF @@FETCH_STATUS <> 0
         BREAK

      SELECT @last_updateby = @tmwuser

      SELECT @last_updatedate = GETDATE()

      --When existing handle is updated
      IF UPDATE (handle)
      BEGIN
         --Moving Backward
         IF @new_handle = 0
         BEGIN
            IF @old_handle_prior01 <> 0
            BEGIN
               SELECT @new_handle = @old_handle_prior01
               SELECT @old_handle_prior01 = @old_handle_prior02
               SELECT @old_handle_prior02 = 0
            END
            ELSE
            IF @old_handle_prior02 <> 0
            BEGIN
               SELECT @new_handle = @old_handle_prior02
               SELECT @old_handle_prior01 = 0
               SELECT @old_handle_prior02 = 0
            END
         END
         ELSE
         --Moving Forward
         BEGIN
            SELECT @new_handle = @new_handle
            SELECT @old_handle_prior02 = @old_handle_prior01
            SELECT @old_handle_prior01 = @old_handle
         END
         
         UPDATE communicator_handle
            SET last_updateby          = @last_updateby
              , last_updatedate        = @last_updatedate
              , handle                 = @new_handle
              , handle_prior01         = @old_handle_prior01
              , handle_prior02         = @old_handle_prior02
          WHERE communicator_handle_id = @communicator_handle_id
      END
      ELSE
      BEGIN
         UPDATE communicator_handle
            SET last_updateby          = @last_updateby
              , last_updatedate        = @last_updatedate
          WHERE communicator_handle_id = @communicator_handle_id
      END
   END
   CLOSE myCUR
   DEALLOCATE myCUR
END
RETURN
GO
ALTER TABLE [dbo].[communicator_handle] ADD CONSTRAINT [pk_communicator_handle_id] PRIMARY KEY CLUSTERED ([communicator_handle_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[communicator_handle] TO [public]
GO
GRANT INSERT ON  [dbo].[communicator_handle] TO [public]
GO
GRANT REFERENCES ON  [dbo].[communicator_handle] TO [public]
GO
GRANT SELECT ON  [dbo].[communicator_handle] TO [public]
GO
GRANT UPDATE ON  [dbo].[communicator_handle] TO [public]
GO
