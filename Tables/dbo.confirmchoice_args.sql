CREATE TABLE [dbo].[confirmchoice_args]
(
[confirmchoice_args_id] [int] NOT NULL IDENTITY(1, 1),
[confirmchoice_id] [int] NOT NULL,
[seqno] [int] NOT NULL,
[arg] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_updateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itut_confirmchoice_args]
ON [dbo].[confirmchoice_args]
FOR INSERT,UPDATE
AS  
  
/**
 * 
 * NAME:
 * dbo.itut_confirmchoice_args
 *
 * TYPE:
 * Trigger
 *
 * DESCRIPTION:
 * This trigger updates userid, last update date
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
 * 01/30/2012 PTS60176 SPN - Initial Version
 **/
DECLARE @tmwuser                 VARCHAR(255)
DECLARE @last_updateby           VARCHAR(255)
DECLARE @last_updatedate         DATETIME

BEGIN
   EXEC gettmwuser @tmwuser OUTPUT

   SELECT @last_updateby = @tmwuser
   SELECT @last_updatedate = GETDATE()

   UPDATE confirmchoice_args
      SET last_updateby   = @last_updateby
        , last_updatedate = @last_updatedate
    WHERE confirmchoice_args_id IN (SELECT confirmchoice_args_id FROM inserted)
END
RETURN
GO
ALTER TABLE [dbo].[confirmchoice_args] ADD CONSTRAINT [confirmchoice_args_id] PRIMARY KEY CLUSTERED ([confirmchoice_args_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[confirmchoice_args] ADD CONSTRAINT [fk_confirmchoice_args_confirmchoice_id] FOREIGN KEY ([confirmchoice_id]) REFERENCES [dbo].[confirmchoice] ([confirmchoice_id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[confirmchoice_args] TO [public]
GO
GRANT INSERT ON  [dbo].[confirmchoice_args] TO [public]
GO
GRANT REFERENCES ON  [dbo].[confirmchoice_args] TO [public]
GO
GRANT SELECT ON  [dbo].[confirmchoice_args] TO [public]
GO
GRANT UPDATE ON  [dbo].[confirmchoice_args] TO [public]
GO
