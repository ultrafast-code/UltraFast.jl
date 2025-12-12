struct PlainDescent <: Gradients end

# TODO: The conj should not be here:
(m::PlainDescent)(OkconjOkprime, Ok, ElocOkconj, Eloc, iteration) = begin
    print("REMOVE THE conj here")
    return conj(ElocOkconj - (Eloc * conj(Ok)))
end

PlainDescent(settings) = PlainDescent()