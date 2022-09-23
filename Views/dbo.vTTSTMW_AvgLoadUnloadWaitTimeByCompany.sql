SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO







CREATE       View [dbo].[vTTSTMW_AvgLoadUnloadWaitTimeByCompany]

As

Select TempUnloadLoad.*      

From

(


select  vTTSTMW_OrderStopDetail.*,
        datediff(n,Case When [Original Scheduled Date] > [Arrival Date] and ([Original Scheduled Date] < '2049-12-31') Then [Original Scheduled Date] Else [Arrival Date] End,[Departure Date]) as TotalTimeAtCompanyMinutes,
        convert(float,datediff(ss,Case When [Original Scheduled Date] > [Arrival Date] and ([Original Scheduled Date] < '2049-12-31') Then [Original Scheduled Date] Else [Arrival Date] End,[Departure Date]))/3600 as TotalTimeAtCompanyHours,
        Case When [Original Scheduled Date] > [Arrival Date] and ([Original Scheduled Date] < '2049-12-31') Then [Original Scheduled Date] Else [Arrival Date] End as [Used Arrival Date]




from 	vTTSTMW_OrderStopDetail
where 
        [Load Status] = 'LD'
	And
	[Stop Status] = 'DNE'

) As TempUnloadLoad

Where 
      TotalTimeAtCompanyMinutes > 1
      And
      ([Used Arrival Date] > '1950-01-01' and [Used Arrival Date] < '2049-12-31')
      AND
      ([Departure Date] > '1950-01-01' and [Departure Date] < '2049-12-31')






GO
GRANT SELECT ON  [dbo].[vTTSTMW_AvgLoadUnloadWaitTimeByCompany] TO [public]
GO
