CREATE TABLE [dbo].[company_attributes]
(
[ca_id] [int] NOT NULL IDENTITY(1, 1),
[ca_type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[labelfile_abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itut_company_attributes]
ON [dbo].[company_attributes]
FOR INSERT,UPDATE
AS

/**
 *
 * NAME:
 * dbo.itut_company_attributes
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
 * 09/18/2012 PTS62827 SPN - Initial Version
 **/
DECLARE @tmwuser                 VARCHAR(255)
DECLARE @last_updateby           VARCHAR(255)
DECLARE @last_updatedate         DATETIME

BEGIN
   EXEC gettmwuser @tmwuser OUTPUT

   SELECT @last_updateby = @tmwuser
   SELECT @last_updatedate = GETDATE()

   UPDATE company_attributes
      SET last_updateby   = @last_updateby
        , last_updatedate = @last_updatedate
    WHERE ca_id IN (SELECT ca_id FROM inserted)
END
RETURN
GO
ALTER TABLE [dbo].[company_attributes] ADD CONSTRAINT [pk_company_attributes] PRIMARY KEY CLUSTERED ([ca_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_company_attributes_cmp_id] ON [dbo].[company_attributes] ([cmp_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_company_attributes_cmp_id_ca_type] ON [dbo].[company_attributes] ([cmp_id], [ca_type]) INCLUDE ([labelfile_abbr]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_attributes] ADD CONSTRAINT [fk_company_attributes_cmp_id] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[company] ([cmp_id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[company_attributes] TO [public]
GO
GRANT INSERT ON  [dbo].[company_attributes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_attributes] TO [public]
GO
GRANT SELECT ON  [dbo].[company_attributes] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_attributes] TO [public]
GO
