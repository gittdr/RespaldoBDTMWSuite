CREATE TABLE [dbo].[trailer_cleaning_log]
(
[tcl_id] [int] NOT NULL IDENTITY(1, 1),
[tch_id] [int] NULL,
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fbc_compartm_number] [int] NOT NULL CONSTRAINT [DF__trailer_c__fbc_c__483F31E8] DEFAULT ((0)),
[tcl_date] [datetime] NOT NULL CONSTRAINT [DF__trailer_c__tcl_d__49335621] DEFAULT (getdate()),
[tcl_usr] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tcl_answer] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[mov_number] [int] NOT NULL,
[lgh_number] [int] NOT NULL,
[cmd_code] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__trailer_c__cmd_c__4A277A5A] DEFAULT ('UNKNOWN'),
[cmd_class] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__trailer_c__cmd_c__4B1B9E93] DEFAULT ('UNKNOWN'),
[cmd_class2] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__trailer_c__cmd_c__4C0FC2CC] DEFAULT ('UNKNOWN'),
[scm_subcode] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tcl_cleaning_needed] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trailer_cleaning_log] ADD CONSTRAINT [PK__trailer_cleaning__474B0DAF] PRIMARY KEY CLUSTERED ([tcl_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [alt_tcl] ON [dbo].[trailer_cleaning_log] ([trl_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trailer_cleaning_log] TO [public]
GO
GRANT INSERT ON  [dbo].[trailer_cleaning_log] TO [public]
GO
GRANT SELECT ON  [dbo].[trailer_cleaning_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[trailer_cleaning_log] TO [public]
GO
