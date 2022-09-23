SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE                                    View [dbo].[vSSRSRB_DriverTesting]
As
/**
 *
 * NAME:
 * dbo.vSSRSRB_DriverTesting
 *
 * TYPE:
 * View
 *
 * DESCRIPTION:
 * View Creation for SSRS Report Library
 *
 * REVISION HISTORY:
 *
 * 3/19/2014 MREED created 
 **/
select 
mpp_id as 'Driver ID',
drt_testdate as 'Test Date',
drt_description as 'Description',
drt_results as 'Results',
drt_administrator as 'Administrator',
(select labelfile.name from labelfile with (nolock) where labelfile.code = drivertesting.drt_code and labeldefinition = 'DrvTstCd') as 'Code'
 from drivertesting with (nolock)
 

GO
GRANT DELETE ON  [dbo].[vSSRSRB_DriverTesting] TO [public]
GO
GRANT INSERT ON  [dbo].[vSSRSRB_DriverTesting] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vSSRSRB_DriverTesting] TO [public]
GO
GRANT SELECT ON  [dbo].[vSSRSRB_DriverTesting] TO [public]
GO
GRANT UPDATE ON  [dbo].[vSSRSRB_DriverTesting] TO [public]
GO
