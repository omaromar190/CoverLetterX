import { useAuth, googleSignInUrl as signInUrl } from 'wasp/client/auth';
import { VStack, Button, Spinner } from '@chakra-ui/react';
import { AiOutlineGoogle } from 'react-icons/ai';
import BorderBox from './components/BorderBox';
import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

export default function Login() {
  const { data: user, isLoading } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (user) {
      navigate('/');
    }
  }, [user]);

  return (
    <BorderBox>
      {isLoading ? (
        <Spinner />
      ) : (
        <VStack>
          <a href={signInUrl}>
            <Button leftIcon={<AiOutlineGoogle />}>Google Sign In</Button>
          </a>
        </VStack>
      )}
    </BorderBox>
  );
}
