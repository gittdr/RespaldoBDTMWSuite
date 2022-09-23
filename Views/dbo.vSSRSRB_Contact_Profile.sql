SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vSSRSRB_Contact_Profile]

As

SELECT [con_id] as [Contact ID]
      ,[con_asgn_type] as [Assign Type]
      ,[con_print] as [Print]
      ,[con_print_printer] as [Printer]
      ,[con_email] as [Email Address]
      ,[con_email_address1] as [Email Address1]
      ,[con_email_address2] as [Email Address2]
      ,[con_email_printer] as [Email Printer]
      ,[con_email_subject] as [Email Subject]
      ,[con_email_bodytext] as [Body Text]
      ,[con_email_directory] as [Email Directory]
      ,[con_pdf] as [PDF]
      ,[con_work_directory] as [Work Directory]
      ,[con_work_directory_ovr] as [Work Diretory Override]
      ,[con_use_default_coverletter] as [Default Cover Letter]
      ,[con_fax_company] as [Fax Company]
      ,[con_fax_coverfile] as [Fax Cover File]
      ,[con_fax_subject] as [Fax Subject]
      ,[con_fax_to] as [Fax To]
      ,[con_fax] as [FaxYN]
      ,[con_fax_ovr] as [Fax Override]
      ,[con_fax_number] as [Fax Number]
      ,[con_fax_printer] as [Fax Printer]
      ,[con_clear_files] as [Clear Files]
  FROM [dbo].[contact_profile]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_Contact_Profile] TO [public]
GO
