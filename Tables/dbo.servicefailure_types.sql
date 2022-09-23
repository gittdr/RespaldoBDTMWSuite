CREATE TABLE [dbo].[servicefailure_types]
(
[id] [int] NOT NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [char] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[servicefailure_types] ADD CONSTRAINT [sft_type_pk] PRIMARY KEY CLUSTERED ([id], [type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[servicefailure_types] TO [public]
GO
GRANT INSERT ON  [dbo].[servicefailure_types] TO [public]
GO
GRANT SELECT ON  [dbo].[servicefailure_types] TO [public]
GO
GRANT UPDATE ON  [dbo].[servicefailure_types] TO [public]
GO
