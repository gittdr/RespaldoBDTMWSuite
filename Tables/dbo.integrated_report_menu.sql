CREATE TABLE [dbo].[integrated_report_menu]
(
[ir_id] [int] NOT NULL,
[irm_sequence] [int] NOT NULL,
[irm_datawindow] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[irm_menu_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[irm_multi_retrieve_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irm_report_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__integrate__irm_r__56CEAD45] DEFAULT ('C'),
[irm_window_datawindow] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__integrate__irm_w__57C2D17E] DEFAULT ('N'),
[irm_dw_retrieveend] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__integrate__irm_d__58B6F5B7] DEFAULT ('N'),
[irm_dw_rowfocuschanged] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__integrate__irm_d__59AB19F0] DEFAULT ('N'),
[irm_dw_itemchanged] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__integrate__irm_d__5A9F3E29] DEFAULT ('N'),
[irm_dw_titlebar_onoff] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__integrate__irm_d__5B936262] DEFAULT ('N'),
[irm_dw_titlebar_text] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irm_dw_controlmenu_onoff] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__integrate__irm_d__5C87869B] DEFAULT ('N'),
[irm_dw_hscrollbar_onoff] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__integrate__irm_d__5D7BAAD4] DEFAULT ('N'),
[irm_dw_vscrollbar_onoff] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__integrate__irm_d__5E6FCF0D] DEFAULT ('N'),
[irm_dw_resizable_onoff] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__integrate__irm_d__5F63F346] DEFAULT ('N'),
[irm_dw_livescroll_onoff] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__integrate__irm_d__6058177F] DEFAULT ('N'),
[irm_dw_border_onoff] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__integrate__irm_d__614C3BB8] DEFAULT ('N'),
[irm_dw_border_style] [smallint] NOT NULL CONSTRAINT [DF__integrate__irm_d__62405FF1] DEFAULT (2),
[irm_dw_x] [int] NULL CONSTRAINT [DF__integrate__irm_d__6334842A] DEFAULT (0),
[irm_dw_y] [int] NOT NULL CONSTRAINT [DF__integrate__irm_d__6428A863] DEFAULT (0),
[irm_dw_height] [int] NOT NULL CONSTRAINT [DF__integrate__irm_d__651CCC9C] DEFAULT (0),
[irm_dw_width] [int] NOT NULL CONSTRAINT [DF__integrate__irm_d__6610F0D5] DEFAULT (0),
[irm_dw_visible_expression] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irm_dw_itemchanged_column_list] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irm_window] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irm_window_dw_control] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irm_floating_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irm_auto_hide] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[integrated_report_menu] ADD CONSTRAINT [pk_integrated_report_menu] PRIMARY KEY NONCLUSTERED ([ir_id], [irm_sequence], [irm_datawindow]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ivd_irm_window] ON [dbo].[integrated_report_menu] ([irm_window]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[integrated_report_menu] TO [public]
GO
GRANT INSERT ON  [dbo].[integrated_report_menu] TO [public]
GO
GRANT REFERENCES ON  [dbo].[integrated_report_menu] TO [public]
GO
GRANT SELECT ON  [dbo].[integrated_report_menu] TO [public]
GO
GRANT UPDATE ON  [dbo].[integrated_report_menu] TO [public]
GO
