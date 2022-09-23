CREATE TABLE [dbo].[custom_sort]
(
[csrt_id] [int] NOT NULL IDENTITY(1, 1),
[csrt_sort_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csrt_window] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csrt_dwctrl] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csrt_dwobj] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csrt_default] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__custom_so__csrt___2031408E] DEFAULT ('N'),
[csrt_enable_rmbsort] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__custom_so__csrt___212564C7] DEFAULT ('N'),
[csrt_created_date] [datetime] NULL,
[csrt_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csrt_modified_date] [datetime] NULL,
[csrt_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccsrt_sort] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[custom_sort] ADD CONSTRAINT [pk_custom_sort] PRIMARY KEY CLUSTERED ([csrt_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[custom_sort] TO [public]
GO
GRANT INSERT ON  [dbo].[custom_sort] TO [public]
GO
GRANT SELECT ON  [dbo].[custom_sort] TO [public]
GO
GRANT UPDATE ON  [dbo].[custom_sort] TO [public]
GO
