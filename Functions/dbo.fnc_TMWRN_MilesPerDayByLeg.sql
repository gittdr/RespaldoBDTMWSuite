SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


















--select * from stops where lgh_number = 1076 

--Select * from fnc_TMWRN_MilesPerDayByLeg ('4/1/1999','11/1/2003') 

CREATE       Function [dbo].[fnc_TMWRN_MilesPerDayByLeg] (@DateStart datetime, @DateEnd datetime) 

Returns @Days Table (LegNumber int,WorkDate datetime,MinsAllotedForDay float,AllocatedMilesByDay int,MinsPctPerDay float)

 

As 

Begin 

 

--Declarations 

 

Declare @Stops Table (StopNumber int,Leg int,Miles int,StopDate datetime,ArrivalDate datetime,DepartureDate datetime,EventCode varchar(100))

Declare @Miles int 

Declare @seq int 

Declare @MinsAllotedForDay int 

Declare @LegList Table (LGHNumber int) 

Declare @LastStopDate datetime 

Declare @FirstStopDate datetime 

 

 

 

Declare @DateRangeDays Table (WorkDate datetime) 

 

 

 

Insert into @Stops(StopNumber,Leg,Miles,StopDate,ArrivalDate,DepartureDate,EventCode) 

Select stp_number,lgh_number,IsNull(stp_lgh_mileage,0),Case When stp_departure_status = 'DNE' Then stp_departuredate Else stp_arrivaldate End,stp_arrivaldate,stp_departuredate,stp_event

 

From   stops (NOLOCK) 

Where Case When stp_departure_status = 'DNE' Then  stp_departuredate Else stp_arrivaldate End  >= @DateStart 

      and 

      Case When stp_departure_status = 'DNE' Then  stp_departuredate Else stp_arrivaldate End  < DateAdd(day,1,@DateEnd)

 

      and 

      stp_status = 'DNE' 

--lgh_number = @LegNumber 

 

Insert into @LegList(LGHNumber) 

Select Distinct Leg From @Stops 

 

Insert into @Stops(StopNumber,Leg,Miles,StopDate,ArrivalDate,DepartureDate,EventCode) 

Select stp_number,lgh_number,IsNull(stp_lgh_mileage,0),Case When stp_departure_status = 'DNE' Then stp_departuredate Else stp_arrivaldate End,stp_arrivaldate,stp_departuredate,stp_event

 

From   stops (NOLOCK) 

Where  not exists (select stopnumber from @stops where stopnumber = stp_number and lgh_number = Leg) 

       and 

       lgh_number in (select lghnumber from @LegList) 

       and 

       stp_status = 'DNE' 

 

 

 

Set @LastStopDate = (select max(cast(convert(varchar(50),StopDate,101) as datetime)) from @Stops) 

Set @FirstStopDate = (select min(cast(convert(varchar(50),StopDate,101) as datetime)) from @Stops where StopDate > '1/1/1950')

 

 

 

while @FirstStopDate <= @LastStopDate 

begin 

 

insert into @DateRangeDays values (@FirstStopDate) 

 

 

 

 

Set @FirstStopDate = DateAdd(day,1,@FirstStopDate) 

end 

 

 

 

 

 

 

 

Insert into @Days 

Select LGHNumber,WorkDate,0,0,0 From @LegList,@DateRangeDays Where WorkDate Between (select min(cast(convert(varchar(50),StopDate,101) as datetime)) from @Stops where Leg = LghNumber) and (select max(cast(convert(varchar(50),StopDate,101) as datetime)) from @Stops where Leg = LghNumber)

 

 

 

 

Update @Days Set MinsAllotedForDay  = 

 

                        Case When WorkDate Between (select min(cast(convert(varchar(50),StopDate,101) as datetime)) from @Stops where Leg = LegNumber) and  (select max(cast(convert(varchar(50),StopDate,101) as datetime)) from @Stops where Leg = LegNumber) Then

 

                                DateDiff(mi,Case When (select min(StopDate) from @Stops where Leg = LegNumber) < WorkDate Then WorkDate Else (select min(StopDate) from @Stops where Leg = LegNumber) End,Case When (select max(StopDate) from @Stops where Leg = LegNumber) < DateAdd(day,1,WorkDate) Then (select max(StopDate) from @Stops where Leg = LegNumber) Else DateAdd(day,1,WorkDate) End)

 

                        Else 

                                0 

                        End 

                


--Deduct time where driver goes home
Update @Days Set MinsAllotedForDay = MinsAllotedForDay -  

							IsNull((
							select sum(a.minstodedcut)

							From
							(select minstodedcut=
								DateDiff(mi,case when ArrivalDate < WorkDate Then WorkDate Else ArrivalDate End,Case When DepartureDate > WorkDate Then WorkDate Else DepartureDate End)
							   From   @Stops
							   Where  Leg = LegNumber
								  And
								  EventCode = 'DRVH'
								  --And 
								  --WorkDate Between convert(datetime,convert(varchar(100),ArrivalDate)) and convert(datetime,convert(varchar(100),DepartureDate))
								  
						          ) as a

					),0)

								  
--case when (select min(ArrivalDate)  

 

insert into @Days Select NULL,WorkDate,0,0,0 From @DateRangeDays 

 

--Update @Days Set MinsAllotedForDay = case when (select ArrivalDate  

 

 

 

/*Set @seq = 1 

 

 

 

Set @Leg = (select min(Leg) from @Stops) 

 

While @Leg Is Not Null 

Begin 

 

set @DateStart = (select min(cast(convert(varchar(50),StopDate,101) as datetime)) from @Stops where Leg = @Leg) 

while @DateStart <= (select max(cast(convert(varchar(50),StopDate,101) as datetime)) from @Stops where Leg = @Leg) 

begin 

 

        Set @MinsAllotedForDay = 

        Case When @seq = 1 and @DateStart = (select min(cast(convert(varchar(50),StopDate,101) as datetime)) from @Stops where Leg = @Leg) Then

 

                DateDiff(mi,(select min(StopDate) from @Stops),DateAdd(day,1,@DateStart))       

             When @DateStart = (select max(cast(convert(varchar(50),StopDate,101) as datetime)) from @Stops Where Leg = @Leg) Then              

 

                DateDiff(mi,@DateStart,(select max(StopDate) from @Stops where Leg = @Leg))     

             Else 

                1440 

        End 

 

 

 

        insert into @Days values (@Leg,@DateStart,@MinsAllotedForDay,0,0) 

 

        Set @seq = @seq + 1 

        Set @DateStart = DateAdd(day,1,@DateStart) 

end 

 

        Set @Leg = (select min(Leg) from @Stops where Leg > @Leg) 

end 

 

--select * from @Days 

 

 

 

*/ 

 

 

 

 

Declare @Days2 Table (LegHeaderNumber int,WorkDate datetime,MinsAllotedForDay float,AllocatedMilesByDay int,MinsPctPerDay float)

 

insert into @Days2 

Select * from @Days 

 

Update @Days Set MinsPctPerDay = case when (select sum(b.minsallotedforday) from @Days2 b where legnumber = b.legheadernumber) >0 Then MinsAllotedForDay/ (select sum(b.minsallotedforday) from @Days2 b where legnumber = b.legheadernumber) else 0 end

 

         

 

Update @Days Set AllocatedMilesByDay = (MinsPctPerDay * cast((Select Sum(Miles) from @Stops where LegNumber = Leg) as float))

 

 

 

 

 

Return 

end 

 

 

 

 

 

 

 

 


GO
